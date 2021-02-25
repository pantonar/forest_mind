#!/bin/sh

#Author: Pablo Anton 

#Script launches a spot request for an analysis server (unless an instance is already running)
#This startup script:
#0. Launches a spot request for an analysis server (unless an instance is already running)
#1. Attaches and mounts storage EBS device  to /mnt/storage
#2. Attached and mounts homes EBS device to /home
#3. Allocates elastic IP to this instance
#4. Install JumpCloud user agent
#5. Adds the system to Earth Observation JumpCloud group
set -x

#ENVIRONMENT
REGION=eu-west-3
SHARED_STORAGE_VOLUME_ID=vol-08d65db0d9ead2b1c
HOMES_VOLUME_ID=vol-0fe855f7691eb57b7
ELASTIC_IP=eipalloc-04ade6a030f3671bc
export AWS_PROFILE=images

# 0. Check if instance is running, and launches one if not
INSTANCES_RUNNING=`aws ec2 describe-instances --region $REGION --filters "Name=tag:Purpose,Values=dri-analysis" "Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped" --output text | wc -l`

if [[ $INSTANCES_RUNNING  -eq 0 ]] ; then
  echo "Starting analysis server"
  SPOT_FLEET_REQUEST_ID=`aws ec2 request-spot-fleet --spot-fleet-request-config file://ec2-spot-request-for-analysis.json --region $REGION | jq -r ".SpotFleetRequestId"`
  echo "Spot request made, server should come up in around three minutes"
else
  echo "Analysis server already running"
fi

sleep 90

# Ensure the instance is running
FLEET_REQUEST_STATE="unknown"
until [ "${FLEET_REQUEST_STATE}" == "fulfilled" ]; do
	FLEET_REQUEST_STATE=`aws ec2 describe-spot-fleet-requests --spot-fleet-request-ids $SPOT_FLEET_REQUEST_ID --region $REGION| jq -r ".SpotFleetRequestConfigs[0].ActivityStatus"`
  sleep 10
done;
echo "Fleet request fulfilled"

INSTANCE_ID=`aws ec2 describe-spot-fleet-instances --spot-fleet-request-id $SPOT_FLEET_REQUEST_ID --region $REGION| jq -r ".ActiveInstances[0].InstanceId"`

INSTANCE_STATE="unknown"
until [ "${INSTANCE_STATE}" == "running" ]; do
  INSTANCE_STATE=`aws ec2 describe-instances --instance-id $INSTANCE_ID --region $REGION| jq -r ".Reservations[0].Instances[0].State.Name"`
  sleep 10
done
echo "Instance running"

#Attach elastic IP
aws ec2 associate-address --instance-id ${INSTANCE_ID} --allocation-id ${ELASTIC_IP}  --region $REGION
PUBLIC_DNS=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicDnsName' --output text --region $REGION`
#1. Attach storage-forest-mind EBS device  to /mnt/storage
aws ec2 attach-volume --volume-id ${SHARED_STORAGE_VOLUME_ID} --instance-id ${INSTANCE_ID} --device /dev/sdb --region $REGION

DATA_STATE="unknown"
until [ "${DATA_STATE}" == "attached" ]; do
  DATA_STATE=$(aws ec2 describe-volumes \
    --region $REGION --filters \
    Name=attachment.instance-id,Values=${INSTANCE_ID} \
    Name=attachment.device,Values=/dev/sdb \
    --query Volumes[].Attachments[].State \
    --output text)

  sleep 10
done
echo "storage volume attached"
ssh -i ~/.ssh/images.pem ubuntu@$PUBLIC_DNS 'sudo mount /dev/nvme2n1 /mnt/uksa-storage'
echo "storage volume mounted"

#2. Attached homes-forest-mind EBS device to /home
# first create volume from snapshot andd adjust HOMES_VOLUME_ID
aws ec2 attach-volume --volume-id ${HOMES_VOLUME_ID} --instance-id ${INSTANCE_ID} --device /dev/sdc --region $REGION

DATA_STATE="unknown"
until [ "${DATA_STATE}" == "attached" ]; do
  DATA_STATE=$(aws ec2 describe-volumes \
    --region $REGION --filters \
    Name=attachment.instance-id,Values=${INSTANCE_ID} \
    Name=attachment.device,Values=/dev/sdc \
    --query Volumes[].Attachments[].State \
    --output text)

  sleep 5
done
echo "home volume attached"
ssh -i ~/.ssh/images.pem ubuntu@$PUBLIC_DNS 'sudo mount /dev/nvme3n1 /home'
echo "home volume mounted"

