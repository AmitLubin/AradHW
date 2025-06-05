Create a .env file like:
DOCKER_REGISTRY=releases-docker.jfrog.io
ARTIFACTORY_VERSION=7.63.14
ROOT_DATA_DIR=<full_path_to_this_folder>/volume
JF_ROUTER_ENTRYPOINTS_EXTERNALPORT=8082
NGINX_LOG_ROTATE_COUNT=
NGINX_LOG_ROTATE_SIZE=

Create a folder called 'volume' in this folder.
Inside volume dir you just created, make a folder called 'var'

Next run: sudo chown -R 1030:1030 <full_path_to_this_folder>/volume/var

You can now launch the docker-compose file

To check artifactory go to 'http://localhost:8082/ui/'.
You should now see the login menu

** I thought uploading the volume is bad practice,
   same for .env files