#!/bin/bash
RECORD_NAME="amit.aws.cts.care."
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

public_ip=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
zone_id=$(aws route53 list-hosted-zones | grep -C 1 "aws.cts.care." | head -n 1 | awk -F '/' '{print $3}' | awk -F '"' '{print $1}')

cat <<EOF > change-record.json
{
  "Comment": "Update my record ${RECORD_NAME} with my instance public IP",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          { "Value": "$public_ip" }
        ]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id "$zone_id" --change-batch file://change-record.json