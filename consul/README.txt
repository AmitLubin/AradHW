First run consul via docker-compose file provided.
You may (not must) provide Consul a key-value pair in advance.
The key should be called 'version' and the value should be '<number>.<number>.<number>'
example: 3.4.1
The curl command is: curl -X PUT --data '<number>.<number>.<number>' consul:8500/v1/kv/consul/version

Once up, run the parameterized Jenkinsfile.
* I put Jenkins and Consul on the same docker network

There are 3 parameters:

DECLERATIVE_APPEND - If true, will use the next parameter (VERSION) as the base version
instead of the one provided by Consul

VERSION - If DECLERATIVE_APPEND is true, this will be base version that will be appended

APPENDER (Choices) -
'v' - will append the version (example 1.0.0 -> 2.0.0)
's' - will append the sub-version (example 1.0.0 -> 1.1.0)
'b' - will apeend the build-version (example 1.0.0 -> 1.0.1)
'n' - will not append anything, thus will not push to Consul

You can check if it worked by either running the pipeline again 
with APPENDER set to 'n' and DECLERATIVE_APPEND set to 'false'