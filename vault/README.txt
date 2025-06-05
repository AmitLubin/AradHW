First, create a .env with 2 envs:
VAULT_DEV_ROOT_TOKEN_ID -> secret token that you decide
VAULT_DEV_LISTEN_ADDRESS -> I set it to "0.0.0.0:8200", should listen to all IPV4 
                            on this machine

example of .env:
VAULT_DEV_ROOT_TOKEN_ID=root
VAULT_DEV_LISTEN_ADDRESS="0.0.0.0:8200"

Next, run the docker-compose file

Run the pipeline and insert the according parameters. If you have no parameters appear, it will fail and appear for the next run
now that Jenkins knows your jenkinsfile
The token should be the same you inserted in your .env file