provider "aws" {
  region = "il-central-1"
}

# Get account info (for Lambda permission)
data "aws_caller_identity" "current" {}

# Get existing Lambda function
data "aws_lambda_function" "amit_lambda" {
  function_name = "AmitNetStats"
}

# Get root resource ID of the REST API
data "aws_api_gateway_resource" "root" {
  rest_api_id = var.api_id
  path        = "/"
}

# Create /stats resource
resource "aws_api_gateway_resource" "stats" {
  rest_api_id = var.api_id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "mine"
}

# Add ANY method to /stats
resource "aws_api_gateway_method" "any_stats" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.stats.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integrate ANY /stats with Lambda
resource "aws_api_gateway_integration" "lambda_any_stats" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.stats.id
  http_method             = aws_api_gateway_method.any_stats.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.amit_lambda.invoke_arn
}

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.amit_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api_id}/dev/ANY/mine"
}

# Deploy the API (creates deployment under a stage)
resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_any_stats]
  rest_api_id = var.api_id
  description = "New deployment for /mine route"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                    = "CognitoAuthorizer"
  rest_api_id             = var.api_id
  type                    = "COGNITO_USER_POOLS" 
  provider_arns           = ["arn:aws:cognito-idp:${var.region}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"]
  identity_source         = "method.request.header.Authorization"
}
