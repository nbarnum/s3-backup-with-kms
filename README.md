# s3-backup-with-kms

Proof-of-concept implementation of the [AWS Encryption CLI example script](https://docs.aws.amazon.com/encryption-sdk/latest/developer-guide/crypto-cli-examples.html#cli-example-script).

Terraform managed resources include: S3 Bucket, IAM user, and KMS key for encrypting backups and storing them offsite.

Note: these configurations are not intended for production environments.

## Usage

Generate a test file to compress, encrypt, and upload

```text
$ head -c 100M < /dev/zero > "$(date +%Y%m%d%H%M%S)_test_backup.tmp"
```

Deploy the terraform resources

```text
$ cd terraform/

$ terraform init

$ terraform apply

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

aws_access_key_id = "AAAABBBBCCCCDDDDEEEF"
aws_secret_access_key = "<aws secret access key here>"
kms_key_arn = "arn:aws:kms:us-west-2:111122223333:key/af68b53b-713f-4be7-abc1-ed52c7a236ec"
s3_bucket_id = "backups20240514054042898900000001"
```

Export credentials and KMS key:

```text
$ export masterKey="arn:aws:kms:us-west-2:111122223333:key/af68b53b-713f-4be7-abc1-ed52c7a236ec"
$ export AWS_ACCESS_KEY_ID="AAAABBBBCCCCDDDDEEEF"
$ export AWS_SECRET_ACCESS_KEY="<aws secret access key here>"
```

Run the script:

```text
$ cd ..

$ ./backup.sh 20240513232230_test_backup.tmp test=true s3://backups20240514052319324600000001 backups
>>> Compressed file does not exist, compressing with gzip...
>>> Encrypting 20240513232230_test_backup.tmp.gz...
2024-05-13 23:27:53,067 - MainThread - aws_encryption_sdk_cli - INFO - Collecting plugin "aws-kms" registered by "aws-encryption-sdk-cli 4.1.0"
2024-05-13 23:27:53,209 - MainThread - aws_encryption_sdk_cli - INFO - encrypting file 20240513232230_test_backup.tmp.gz to ./20240513232230_test_backup.tmp.gz.encrypted
>>> Pushing 20240513232230_test_backup.tmp.gz.encrypted
upload: ./20240513232230_test_backup.tmp.gz.encrypted to s3://backups20240514052319324600000001/backups/20240513232230_test_backup.tmp.gz.encrypted
```

## Cleanup

```text
$ cd terraform

$ terraform destroy
```
