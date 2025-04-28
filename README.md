# Passover Homework

This was my work repo and has a lot in it, so I hope this text file will help
you navigate through my Passover homework.

Each directory of a homework task will have further instructions.

* Many tasks have a jenkins pipeline. I have made a Dockerfile for jenkins adding tools
like AWS CLI or Ansible. The Dockerfile is inside the Jenkins folder
run docker-compose up --build

* While Jenkinsfile is what used in the dir, the pipeline should always run from this repo root dir (any cd to dir is made in the pipeline itself)

## Small tasks:

1) Run Hashicorp Vault -\
**path**: `vault/`\
Run Vault via docker, Then run a parameterized Jenkins pipeline that stores a secret \
**(don't put a real secret since its pulling it at a later stage and echo the data)**

2) Change your A record IP address in Amazon Route53 (`amit.aws.cts.care`) via Ansible -\
**path**: `ansible/playbooks/chg_route53.yml`\
Run Ansible playbook that will change your A record IP address


## Tasks:

1) Run Hashicorp Consul - \
**path**: `consul/` \
Run Consul via docker. You may set a ket/value pair in consul, and call the key 'version' \
Run a parameterized Jenkins pipeline that appends the version and saves it to consul

2) Get AWS access/secret keys from Vault and run a Jenkins pipeline that updates your Route53 A record (`amit.aws.cts.care`) to your instance address (ansible-Amit) - \
**path**: `aws/route53/` \
Insert your access/secret keys to Vault via GUI. Then run a pipeline that will retrieve these keys and update your A record to match your EC2 machine

3) Run Jfrog Artifactory (locally) - \
**path**: `artifactory/` \
Run artifactory locally (just up and running, no user login)

4) Install Artifactory remotely on your EC2 instance - \
**path**: `ansible/playbooks/artifactory.yml` \
Install Artifactory on your EC2 Instance via Ansible (again, no user login)

5) Create a tunnel, via OpenVPN, from your machine to your EC2 instance \
**path**: `openvpn/` \
Install OpenVPN via ansible on your EC2 instance, get a tunnel opener and run it to activate a tunnel from your machine to your EC2 instance

6) Use cloud_init in order to change your Route53 A record (`amit.aws.cts.care`) \
 IP address to match your EC2 instance (ansible-Amit) via meta-data \
**path***: you'll need to ssh `ubuntu@amit.aws.cts.care` \
Created a file called `auto_dns.sh` (gave it permissions ofcourse), \
the file generates a token to retrieve AWS meta-data I need to know my current IP. \
Then after getting my hosted_zone ID i change my record value to my instance public IP \
Added a file `99-<something I forgot and can't check because ec2 is down>.cfg`
to the dir `/etc/cloud/cloud.cfg.d/` \
Then, typed these 4 commands in terminal: \
    ```
    cloud-init clean
    cloud-init init
    cloud-init modules --mode=config
    cloud-init modules --mode=final
    ```

7) Same as #6 only via ansible \
**path**: `ansible/playbooks/cloud_init.yml` \
Ansible should copy a conf file, and shell file to th EC2 instance, then apply the changes to cloud-init

8) Use Jenkins to insert a port var into consul. Extract the port via Ansible and run nginx on your remote machine \
**path**: `consul/nginx_port` \
Two versions for this task: 
    * A normal more complex that installs nginx on the machine and copies a conf file
    * A 'cheating' Docker version that runs nginx on a container and sets port like: `<my consul port var>:80`