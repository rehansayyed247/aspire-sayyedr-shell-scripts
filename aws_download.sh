#!/bin/bash

<< Task
To download files from AWS
with validations
Task

# Function to check if AWS CLI is installed or not
check_aws_cli() {
echo "Checking if AWS CLI is installed or not..."
aws --version
}

# Function to check AWS connectivity to S3 bucket
check_aws_connectivity() {
echo "Checking AWS Connectivity..."
aws iam get-user --user-name srv_download
}

# List buckets in the AWS Account
list_buckets() {
aws s3 ls s3://sayyedr-archive > file_list.log
if [ -f file_list.log ]; then
	echo "Log file exist"
else
	echo "Creating log file..."
	touch file_list.log
fi
}

# Validations
check_validations() {
filename=$(awk -F ' ' '{print $4}' file_list.log)
if [[ $filename == MK* || $filename == V* ]]; then
        echo "File name is valid starting with MK or V"
else
        echo "Invalid file name: $filename"
fi
}

# Function Call
if ! check_aws_cli; then
	echo "AWS CLI is not installed...Please install it"
	exit 1
fi

if ! check_aws_connectivity; then
	echo "AWS Account is not configured"
	exit 1
fi

list_buckets

check_validations
