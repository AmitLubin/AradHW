All you need to do is run this command:
ansible-playbook -i hosts.yaml cloud_init.yaml

Inorder to check, you can insert a random value into amit.aws.cts.care in Route53 records.
After a reboot of the instance, in Route53 the record of amit.aws.cts.care should have the save value as ansible-Amit instance public IP