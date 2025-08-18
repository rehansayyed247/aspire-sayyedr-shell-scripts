#!/bin/bash
#
# Sayyedr Project
# Script to download files from AWS S3 with validations
#

########################
# Global Variables
########################
DOWNLOAD_DIR=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/STUDY_DOWNLOAD
LOG_FILE=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/aws_download.log
ERR_LOG_FILE=/mnt/data/Aspire/aspire-sayyedr-shell-scripts/aws_download_err.log
IAM_USER=srv_download
S3_BUCKET=s3://sayyedr-archive/
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

########################
# Logging Functions
########################
log_with_time() {
    while IFS= read -r line; do
        printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$line"
    done
}

log_info() {
    echo "$*" | log_with_time | tee -a "$LOG_FILE"
}

log_error() {
    echo "ERROR: $*" | log_with_time | tee -a "$ERR_LOG_FILE" >&2
}

rotate_logs() {
	if [ -f "$LOG_FILE" ]; then
	mv "$LOG_FILE" "$LOG_FILE-$TIMESTAMP.log"
	fi
}

########################
# Function to check if cron job is running
########################
check_cron() {
    LOCKFILE="/tmp/$(basename $0).lock"

    exec 200>"$LOCKFILE"   # Open file descriptor 200 for locking

    if ! flock -n 200; then
        log_error "Another instance of $0 is already running. Aborting!"
        exit 1
    fi

    log_info "No duplicate cron job found. Proceeding further..."
}


########################
# Function to check if AWS CLI is installed
########################
check_aws_cli() {
    log_info "Checking if AWS CLI is installed..."

    if ! command -v aws >/dev/null 2>&1; then
        log_error "AWS CLI is not installed. Please install it."
        exit 1
    else
        log_info "AWS CLI is installed: $(aws --version 2>&1)"
    fi
}


########################
# Function to check AWS connectivity
########################
check_aws_connectivity() {
    log_info "Checking AWS connectivity for user: $IAM_USER"

    if ! aws iam get-user --user-name "$IAM_USER" > /tmp/aws_user.json 2>>"$ERR_LOG_FILE"; then
        log_error "AWS connectivity failed. Suggest updating AWS credentials."
        exit 1
    else
        log_info "AWS account is configured."
        iam_user=$(grep '"UserName"' /tmp/aws_user.json | sed -n 's/.*"UserName": *"\([^"]*\)".*/\1/p')
        log_info "IAM User Name: $iam_user"
    fi
}


########################
# List buckets in the AWS Account
########################
list_buckets() {
    log_info "Listing S3 bucket contents for $S3_BUCKET"

    if aws s3 ls "$S3_BUCKET" >>"$LOG_FILE" 2>>"$ERR_LOG_FILE"; then
        log_info "S3 bucket listed successfully."
    else
        log_error "Failed to list S3 bucket: $S3_BUCKET"
        exit 1
    fi
}


########################
# Validations
########################
check_validations() {
    log_info "Validating downloaded file names..."

    # Get the last file name from log (field 4 or 5 depending on aws s3 ls output)
    filename=$(grep -E '\.tgz$' "$LOG_FILE" | awk '{print $4}' | tail -n 1)

    if [[ "$filename" == MK* || "$filename" == V* ]]; then
        log_info "File name is $filename"
        log_info "File name is valid (starts with MK or V)."
    else
        log_error "Invalid file name: $filename"
	send_mail
	exit 1
    fi
}


########################
# Download from AWS
#######################
aws_download() {
log_info "Running the download of file"

if [ -d "$DOWNLOAD_DIR" ]; then
	log_info "Study Folder available"
else
	log_error "No Study Folder, creating one..."
        mkdir "$DOWNLOAD_DIR"
fi

if aws s3 cp "$S3_BUCKET" "$DOWNLOAD_DIR" --recursive >>"$LOG_FILE" 2>>"$ERR_LOG_FILE"; then
	log_info "Download Succeeded"
else
	log_error "Download Failed"
fi
}



########################
# Email (placeholder)
########################
send_mail() {
    log_info "Sending email notification..."
    # TODO: Add mail command or SES integration here
}


########################
# Main Script Execution
########################
check_cron
rotate_logs
check_aws_cli
check_aws_connectivity
list_buckets
check_validations
aws_download
# send_mail   # Uncomment when implemented
