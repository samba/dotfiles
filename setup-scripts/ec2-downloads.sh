#!/bin/sh

DOWNLOADS=${HOME}/Downloads/Workspace

download (){ 
  URL="$1" DEST="${2:-`basename "$1"`}"
  curl -ks -C - -L "${URL}" -o "${DOWNLOADS}/${DEST}"
}

# EC2_API_TOOLS=http://www.amazon.com/gp/redirect.html/ref=aws_rc_ec2tools?location=http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip&token=A80325AA4DAB186C80828ED5138633E3F49160D9

queue_downloads () {
  mkdir -p ${DOWNLOADS}
  download http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip &
  download http://ec2-downloads.s3.amazonaws.com/ElasticLoadBalancing.zip &
  download https://s3.amazonaws.com/cloudformation-cli/AWSCloudFormation-cli.zip &
  download https://s3-us-gov-west-1.amazonaws.com/elasticwolf/ElasticWolf-osx-5.1.1.zip &
  # download https://s3-us-gov-west-1.amazonaws.com/elasticwolf/ElasticWolf-linux-5.1.1.zip &
}


extract_downloads () {
  sudo mkdir -p /usr/local/opt/ec2-api-tools/
  sudo mkdir -p /usr/local/opt/elb-api-tools/
  sudo unzip -d /usr/local/opt/ec2-api-tools ${DOWNLOADS}/ec2-api-tools.zip
  sudo unzip -d /usr/local/opt/elb-api-tools ${DOWNLOADS}/elb-api-tools.zip
}

queue_downloads
wait
extract_downloads
