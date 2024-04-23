# AWS Backup Search Script

This is a Bash script to search for the most recent backups of specified AWS EC2 instances, typically used when running backup checks prior to a maintenance. It will generate a files called 'backup-reports.txt' in the root directory you're seesion is working out of, when the script is run

## Prerequisites

1. AWS Command Line Interface (CLI)
2. IAM User with the necessary permissions to list/describe EC2 instances and snapshots

## Usage

Run the script with the following command:

```bash
./aws_backup_check.sh -a ACCOUNT_NUMBER [-t ACCOUNT_TYPE] -c CTASK -f FILE [-r REGION]
```

### Options:

- `-a ACCOUNT_NUMBER`  
Your AWS account number. This is mandatory.

- `-t ACCOUNT_TYPE`  
Your AWS account type. This can be either 'commercial' or 'govcloud'. This is optional if a region is provided.

- `-c CTASK`  
Your work order number. This is mandatory.

- `-f FILE`  
The path to the file containing your instance names. This is mandatory.

- `-r REGION`  
The AWS region to search. This is optional if an account type is provided.

- `-h`  
Prints the help message.

## Examples

1. Search for backups in a specific region:

```bash
./aws_backup_check.sh -a your_account_number -c ctask -f instances.txt -r us-east-1
```

2. Search for backups in regions for a specific account type:

```bash
./aws_backup_check.sh -a your_account_number -t commercial -c ctask -f instances.txt
```

or

```bash
./aws_backup_check.sh -a your_account_number -t govcloud -c ctask -f instances.txt
```

3. Search for backups in all available regions:

```bash
./aws_backup_check.sh -a your_account_number -c ctask -f instances.txt
```
```
