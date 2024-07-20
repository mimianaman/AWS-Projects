#!/bin/bash

# Configuration
SOURCE_DIR="/home/ubuntu/System_Data"
BACKUP_DIR="/home/ubuntu/System_backup"
BACKEDUP_FILE="backup_$(date +%Y%m%d).tar.gz"
DEST_BUCKET="s3://test-backup-bucket2024"
ADMIN_EMAIL="anamanwilhemina@gmail.com"

# Function to send email notification using mutt
send_email() {
    local subject=$1
    local message=$2
    echo "$message" | mutt -s "$subject" "$ADMIN_EMAIL"
}

# Notify that the backup process has started
send_email "Backup Started" "The backup process has started."

# Create the backup
tar -czf "$BACKUP_DIR/$BACKEDUP_FILE" -C "$SOURCE_DIR" .
if [ $? -eq 0 ]; then
    # Upload the file to S3 
    aws s3 cp "$BACKUP_DIR/$BACKEDUP_FILE" "$DEST_BUCKET/$BACKEDUP_FILE"
    if [ $? -eq 0 ]; then
        # If successful, notify success
        send_email "Backup Successful" "The backup process completed successfully."
    else
        # If upload failed, notify failure
        send_email "Backup Failed" "The backup process failed during upload. Please check the server."
    fi 
else
    # If backup creation failed, notify failure
    send_email "Backup Failed" "The backup process failed during backup creation. Please check the server."
fi
