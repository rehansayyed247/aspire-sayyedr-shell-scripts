#!/bin/bash

<< Task
Sayyedr Project
To download files from AWS
with validations
Task

# Global Variables Declare
CRON_LOG_FILE=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/cron_job.log
IAM_USER=srv_download
S3_BUCKET=s3://sayyedr-archive
LOG_FILE=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/aws_download.log
S3_LOG_FILE=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/s3_file.log
ERR_LOG_FILE=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/aws_download_err.log

# Function to check if cron job is running or not
check_cron() {
echo "Checking if a cron job for this script is running or not..."
ps -ef | grep "/bin/bash $0"|grep -v grep > $CRON_LOG_FILE
if [ -f $CRON_LOG_FILE ]; then
	echo "Cron job log file exist."
else
	echo "No Cron job log file exist...creating one.."
	touch $CRON_LOG_FILE
	echo "Created cron job log file"
fi
	ps -ef | grep "/bin/bash $0" >> /dev/null
	CNT=$(cat $CRON_LOG_FILE | wc -l)
if [ $CNT -gt 1 ]; then
	echo " ERROR: Process Already Running!!!!. So Aborting Job For " "$0" date | tee -a $CRON_LOG >> $ERR_LOG_FILE
	exit 1
else
	echo "No running cron job found for this script. Hence proceeding further..."
fi
}

# Function to check if AWS CLI is installed or not
check_aws_cli() {
echo "Checking if AWS CLI is installed or not..."
aws --version >> /dev/null
if [ $0 ]; then
	echo "AWS CLI is installed"
else
	echo "ERROR: AWS CLI is not installed. Please install it." >> $ERR_LOG_FILE
	exit 1
fi
}

# Function to check AWS connectivity to S3 bucket
check_aws_connectivity() {
echo "Checking AWS Connectivity..."
aws iam get-user --user-name $IAM_USER > $LOG_FILE
if [ ! $0 ]; then
	echo "There is a problem in AWS Connectivity, Suggest to update AWS Credentials" >> $ERR_LOG_FILE
	exit 1
else
	echo "AWS Account is Configured"
	iam_user=$(grep "UserName" $LOG_FILE | sed -n 's/.*"UserName": *"\([^"]*\)".*/\1/p')
	echo "IAM User Name: $iam_user"
fi
}

# List buckets in the AWS Account
list_buckets() {
aws s3 ls $S3_BUCKET > $S3_LOG_FILE
if [ -f $S3_LOG_FILE ]; then
	echo "S3 Log file exist"
else
	echo "Creating log file..."
	touch $S3_LOG_FILE
fi
}

# Validations
check_validations() {
filename=$(awk -F ' ' '{print $4}' $S3_LOG_FILE)
if [[ $filename == MK* || $filename == V* ]]; then
        echo "File name is valid starting with MK or V"
else
        echo "Invalid file name: $filename"
fi
}

# Email
send_mail() {
	echo "Sending Email"
	#Add your logic here
}

# Function Call: Add all your function call here
check_cron
check_aws_cli
check_aws_connectivity
list_buckets
check_validations
