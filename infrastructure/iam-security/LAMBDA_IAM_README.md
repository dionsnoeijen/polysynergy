# Lambda IAM Role Configuration

This directory contains the Terraform configuration for the Lambda execution role with proper S3, DynamoDB, and Secrets Manager permissions.

## What This Fixes

Previously, Lambda functions had a manually created IAM role (`PolySynergyLambdaExecution`) without S3 permissions, causing:
- ❌ **403 Forbidden errors** when accessing S3 files
- ❌ Agent file processing failures in production
- ❌ Knowledge base document loading failures

Now, the role is managed via Terraform with comprehensive permissions.

## Permissions Granted

The Lambda execution role (`PolySynergyLambdaExecution`) now has:

### 1. **S3 Access** (Critical!)
- Read/write access to all PolySynergy S3 buckets:
  - `polysynergy-public-*`
  - `polysynergy-private-*`
  - `polysynergy-lambdas`
  - `polysynergy-*-*-media`
- Operations: GetObject, PutObject, DeleteObject, ListBucket, HeadObject

### 2. **DynamoDB Access**
- Full access to all PolySynergy DynamoDB tables
- Required for: Agent memory, flow state, execution data

### 3. **Secrets Manager Access**
- Read access to all PolySynergy secrets
- Required for: API keys, credentials, sensitive configuration

### 4. **ECR Access**
- Pull container images from ECR
- Required for: Lambda container deployments

### 5. **CloudWatch Logs**
- Write logs to CloudWatch
- AWS managed policy: `AWSLambdaBasicExecutionRole`

## Deployment

### Initial Setup (if role doesn't exist yet)

```bash
cd /Users/dionsnoeijen/polysynergy/orchestrator/infrastructure

# Initialize Terraform (if needed)
terraform init

# Plan to see what will be created
terraform plan

# Apply the changes
terraform apply
```

### If Role Already Exists Manually

If the `PolySynergyLambdaExecution` role was created manually in AWS Console:

**Option 1: Import Existing Role**
```bash
cd /Users/dionsnoeijen/polysynergy/orchestrator/infrastructure

# Import the existing role into Terraform state
terraform import module.iam_security.aws_iam_role.lambda_execution_role PolySynergyLambdaExecution

# Then apply to add the policies
terraform apply
```

**Option 2: Delete and Recreate**
```bash
# 1. Delete the manual role in AWS Console (IAM → Roles → PolySynergyLambdaExecution)
# 2. Run Terraform
terraform apply
```

**⚠️ WARNING**: If you delete the role, existing Lambda functions will temporarily lose permissions until Terraform recreates it with the same name.

### Verify Permissions

After applying, verify the role has all permissions:

```bash
# Check the role in AWS Console
open "https://console.aws.amazon.com/iam/home#/roles/PolySynergyLambdaExecution"

# Or use AWS CLI
aws iam list-attached-role-policies --role-name PolySynergyLambdaExecution
aws iam list-role-policies --role-name PolySynergyLambdaExecution
```

You should see these attached policies:
- ✅ AWSLambdaBasicExecutionRole (managed)
- ✅ PolySynergyLambdaS3Access (custom)
- ✅ PolySynergyLambdaDynamoDBAccess (custom)
- ✅ PolySynergyLambdaSecretsAccess (custom)
- ✅ PolySynergyLambdaECRAccess (custom)

## Testing

After deployment, test that S3 access works:

1. **Trigger a flow** that uses file processing (e.g., DocumentKnowledge node)
2. **Check Lambda logs** - you should NO LONGER see:
   ```
   S3 object not found: ... - An error occurred (403) when calling the HeadObject operation: Forbidden
   ```
3. **Verify success** - files should be processed correctly

## Files

- `lambda_roles.tf` - Lambda IAM role and policies
- `outputs.tf` - Exports Lambda role ARN for use in other modules
- `variables.tf` - Configuration variables

## Outputs

The module exports:
- `lambda_execution_role_arn` - Full ARN of the Lambda execution role
- `lambda_execution_role_name` - Role name (always: "PolySynergyLambdaExecution")

These can be referenced in other Terraform modules or used in the API service configuration.

## Troubleshooting

### Still Getting 403 Errors?

1. **Check role is attached to Lambda functions**:
   ```bash
   aws lambda get-function --function-name <your-function-name> --query 'Configuration.Role'
   ```
   Should return: `arn:aws:iam::754508895309:role/PolySynergyLambdaExecution`

2. **Verify policies are attached**:
   ```bash
   aws iam list-attached-role-policies --role-name PolySynergyLambdaExecution
   ```

3. **Check bucket permissions**: Ensure the S3 buckets don't have bucket policies that deny access

### Lambda Can't Assume Role?

Check the trust policy allows Lambda service:
```bash
aws iam get-role --role-name PolySynergyLambdaExecution --query 'Role.AssumeRolePolicyDocument'
```

Should include:
```json
{
  "Principal": {
    "Service": "lambda.amazonaws.com"
  }
}
```

## Maintenance

When adding new S3 buckets or DynamoDB tables, update the resource ARNs in `lambda_roles.tf` to include the new resources.

Example - adding a new bucket pattern:
```terraform
Resource = [
  "arn:aws:s3:::polysynergy-public-*/*",
  "arn:aws:s3:::polysynergy-new-bucket/*",  # Add new bucket
  # ...
]
```

Then run `terraform apply` to update the policies.
