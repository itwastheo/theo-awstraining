# AWS IAM & Policy Configuration – Hands-On Lab Walkthrough

This walkthrough guides you step-by-step on configuring AWS IAM (Identity and Access Management) users, groups, roles, and policies.

---

## Prerequisites

- AWS Console access (Sandbox or training account).
- Administrator-level permissions to create IAM resources.

---

## Step 1: Create IAM Users

1. **Log in** to the [AWS Management Console](https://console.aws.amazon.com/iam/).
2. Navigate to **IAM > Users**.
3. Click **"Add users"**.
   - Enter two user names: e.g., `DevUser1`, `DevUser2`.
   - Select **"AWS Management Console access"**.
   - Set a custom password or auto-generated.
   - Click **"Next"**, skip permissions (you'll assign via groups), then click **"Create user"**.

---

## Step 2: Create an IAM Group

1. Navigate to **IAM > User groups**.
2. Click **"Create group"**.
3. Enter a group name: e.g., `Developers`.
4. Attach a built-in policy (e.g., **"ReadOnlyAccess"**) temporarily.
5. Click **"Create group"**.
6. Add your two previously created users (`DevUser1` and `DevUser2`) to this group.

---

## Step 3: Create a Custom IAM Policy

1. Navigate to **IAM > Policies**.
2. Click **"Create policy"**.
3. Select the **JSON tab** and add a policy definition, e.g.:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::example-bucket"
            ]
        }
    ]
}
```

4. Click **"Next: Tags"**, optionally add tags, then click **"Next: Review"**.
5. Name the policy, e.g., `ListS3BucketPolicy`, and click **"Create policy"**.

---

## Step 4: Attach Custom Policy to Group

1. Navigate to **IAM > User groups**.
2. Click the `Developers` group.
3. Under **Permissions**, click **"Add permissions"**, then **"Attach policies"**.
4. Find your custom policy (`ListS3BucketPolicy`) and select it.
5. Click **"Add permissions"** to attach it.

---

## Step 5: Test IAM User Permissions

1. Log out and log back in using one of your IAM user accounts (`DevUser1`).
2. Try accessing AWS services, such as S3:
   - You should be able to list the specific bucket (`example-bucket`) but not others.
   - Attempt other restricted actions to confirm they're correctly denied.

---

## Step 6: Create IAM Role for EC2

1. Navigate to **IAM > Roles**.
2. Click **"Create role"**.
3. Select **"AWS service"**, then choose **"EC2"** as the use case.
4. Attach a policy such as **"AmazonS3ReadOnlyAccess"**.
5. Name your role, e.g., `EC2S3ReadOnlyRole`, and create it.

---

## Step 7: Verify IAM Role in EC2 (Optional)

1. Launch an EC2 instance.
2. Attach the IAM role (`EC2S3ReadOnlyRole`) during instance configuration.
3. Connect to the EC2 instance and verify access by listing S3 buckets via AWS CLI:

```shell
aws s3 ls
```

This confirms your IAM role permissions.

---

## Best Practices

- Always adhere to the **principle of least privilege**.
- Regularly review IAM users, groups, roles, and permissions.
- Enable Multi-Factor Authentication (MFA) for all IAM users.
- Avoid using the root account for regular administrative tasks.

---

## Cleanup (Optional)

After the lab:
- Delete the created IAM users, groups, policies, roles, and EC2 instances to avoid charges or security risks.

---

Congratulations! You've successfully completed the AWS IAM & Policy Configuration lab.

