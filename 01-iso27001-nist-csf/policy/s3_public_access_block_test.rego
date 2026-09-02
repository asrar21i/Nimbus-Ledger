package terraform.s3

import rego.v1

test_deny_when_s3_public_access if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_public_access_block.customer_docs",
                "type": "aws_s3_bucket_public_access_block",
                "change": {
                    "after": {
                        "block_public_acls": false,
                        "block_public_policy": true,
                        "ignore_public_acls": true,
                        "restrict_public_buckets": true
                    }
                }
            }
        ]
    }

    count(result) == 1
}

test_pass_when_s3_public_access_is_blocked if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_public_access_block.customer_docs",
                "type": "aws_s3_bucket_public_access_block",
                "change": {
                    "after": {
                        "block_public_acls": true,
                        "block_public_policy": true,
                        "ignore_public_acls": true,
                        "restrict_public_buckets": true
                    }
                }
            }
        ]
    }

    count(result) == 0
}