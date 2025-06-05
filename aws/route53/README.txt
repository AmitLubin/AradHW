First run Vault and enter the GUI (port 8082)
In oreder to run Vault don't forget you'll need a .env file in Vault directory
put these in the .env:
VAULT_DEV_ROOT_TOKEN_ID=root
VAULT_DEV_LISTEN_ADDRESS="0.0.0.0:8200"

The secret path should be 'aws/key'
The key/value pairs are:
1) key: access_key, value: <aws access key>
2) key: secret_key, value: <aws secret key>

Leave AWS_CONFIGURE as unchecking is more for debug (skipping AWS configure and just running last part of Route53)
Insert the IP address you want the record to change (The requested was 'ansible-Amit' public IP)

Run the Jenkins pipeline and check the address in Route53