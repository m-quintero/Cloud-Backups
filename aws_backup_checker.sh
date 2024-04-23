# AWS BACKUP CHECK SCRIPT V2, AUTHOR: MIKE QUINTERO, michael.quintero@rackspace.com
# PURPOSE: To verify the final backups for a list of given AWS EC2 instances
#
#    -a your_account_number sets your AWS account number.
#    -t commercial or -t govcloud sets your AWS account type.
#    -c ctask sets your work order number.
#    -f instances.txt sets the path to the file containing your instance names.
#    -r us-east-1 sets the AWS region.

#!/bin/bash

print_help() {
    echo "Usage: $0 -a ACCOUNT_NUMBER [-t ACCOUNT_TYPE] -c CTASK -f FILE [-r REGION]"
    echo
    echo "Search for the most recent backups of specified AWS EC2 instances."
    echo
    echo "Options:"
    echo "-a ACCOUNT_NUMBER     Your AWS account number."
    echo "-t ACCOUNT_TYPE       Your AWS account type, either 'commercial' or 'govcloud'. Optional if a region is provided."
    echo "-c CTASK              Your work order number."
    echo "-f FILE               Path to the file containing your instance names."
    echo "-r REGION             AWS region to search. Optional if an account type is provided."
    echo "-h                    Print this help message."
    exit 0
}


ACCOUNT_NUMBER=""
ACCOUNT_TYPE=""
CTASK=""
INSTANCE_NAMES_FILE=""
REGION=""

while getopts a:t:c:f:r:h flag
do
    case "${flag}" in
        a) ACCOUNT_NUMBER=${OPTARG};;
        t) ACCOUNT_TYPE=${OPTARG};;
        c) CTASK=${OPTARG};;
        f) INSTANCE_NAMES_FILE=${OPTARG};;
        r) REGION=${OPTARG};;
        h) print_help;;
    esac
done

CURRENT_DATE=$(date +%F)
FILE_NAME="backup-reports"

if [ -n "$CTASK" ]; then
    FILE_NAME="${FILE_NAME}-${CTASK}"
fi

FILE_NAME="${FILE_NAME}-${CURRENT_DATE}.txt"
exec > "$FILE_NAME"

echo "Report generated on: $(date)"
echo "--------------------------------------------------"
echo "Account Number: $ACCOUNT_NUMBER"
echo "CTASK: $CTASK"
echo "--------------------------------------------------"

if [ "$ACCOUNT_TYPE" == "commercial" ]; then
    REGIONS="us-east-1 us-east-2 us-west-1 us-west-2 eu-west-1 eu-west-2 eu-west-3 eu-north-1 eu-central-1 ap-south-1 ap-northeast-2 ap-northeast-1 ap-southeast-1 ap-southeast-2 sa-east-1"
elif [ "$ACCOUNT_TYPE" == "govcloud" ]; then
    REGIONS="us-gov-west-1 us-gov-east-1"
elif [ -n "$REGION" ]; then
    REGIONS=$REGION
else
    REGIONS=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
fi

while IFS= read -r line
do
    for INSTANCE_NAME in $(echo "$line" | tr ',' '\n')
    do
        echo "Instance Name: $INSTANCE_NAME"

        for REGION in $REGIONS
        do
            INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" --region $REGION --query "Reservations[].Instances[].InstanceId" --output text)

            if [ -n "$INSTANCE_ID" ]; then
                echo "Instance ID: $INSTANCE_ID"
                echo "Region: $REGION"
                SNAPSHOT=$(aws ec2 describe-snapshots --owner-ids $ACCOUNT_NUMBER --filters "Name=description,Values=*$INSTANCE_ID*" --region $REGION --query "Snapshots[].[SnapshotId,StartTime]" --output text | sort -k2 -r | head -n1)
                if [ -n "$SNAPSHOT" ]; then
                    echo "Most Recent Snapshot: $SNAPSHOT"
                else
                    echo "No snapshot found for the instance"
                fi
                echo "--------------------------------------------------"
                break
            fi
        done
done
echo "Reading from file: $INSTANCE_NAMES_FILE"

done < "$INSTANCE_NAMES_FILE"

cat $FILE_NAME
