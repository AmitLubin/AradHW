First startconsul via my docker-compose file in consul dir

Next, run the Jenkinsfile in this dir.
The pipeline will insert the port to consul

Now you can use 2 versions of playbooks:

1) Vanilla Nginx install -
run: ansible-playbook -i hosts.yaml nginx_no_docker_port.yml
It will install nginx on your machine and copy the conf file at templates

2) Nginx docker container -
run: ansible-playbook -i hosts.yaml nginx_docker_consul_port.yml
It will launch a docker container of Nginx accessed from the requested port