FROM jenkins/jenkins:latest

USER root

RUN groupadd -g 1001 docker && \
    usermod -aG docker jenkins && \
    apt update && apt install jq -y && rm -rf /var/lib/apt/lists/* && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# RUN apt-get update && \
#     apt-get install -y software-properties-common && \
#     apt-add-repository --yes --update ppa:ansible/ansible && \
#     apt-get install -y ansible && \
#     apt-get clean

RUN apt-get update && \
    apt-get install -y ansible ssh git curl && \
    apt-get clean

USER jenkins