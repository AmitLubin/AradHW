variable "subnet-1" {
    description = "First private network"
    type = string
    default = "subnet-088b7d937a4cd5d85"
}

variable "subnet-2" {
    description = "Second private network"
    type = string
    default = "subnet-01e6348062924d048"
}

variable "security-group" {
    description = "Assigned security group"
    type = string
    default = "sg-0ac3749215afde82a"
}

variable "ami-id" {
    description = "Template AMI ID"
    type = string
    default = "ami-0ae7e1e8fb8251940"
}

variable "auto-scale-name-tag" {
    description = "Auto scale instance name tag"
    type = string
    default = "Amit-ASG"
}

variable "region" {
    description = "AWS Region"
    type = string
    default = "il-central-1"
}