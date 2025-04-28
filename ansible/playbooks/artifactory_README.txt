Commands to run

1: ansible-galaxy collection install community.general ansible.posix
2: ansible-galaxy collection install jfrog.platform
3: MASTER_KEY_VALUE=$(openssl rand -hex 32)
4: JOIN_KEY_VALUE=$(openssl rand -hex 32)
5: ansible-playbook -vv artifactory.yml -i hosts.yaml --extra-vars "master_key=$MASTER_KEY_VALUE join_key=$JOIN_KEY_VALUE"

** I changed artifactory version since the default version didn't work for me.
To change version edit the file at:
<home dir>/.ansible/collections/ansible_collections/jfrog/platform/roles/artifactory/defaults/main.yml
change "artifactory_version" variable to your desired (I used 7.63.14)