package terraform.s3

import rego.v1

test_deny_when_encryption_resource_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "name": "customer_docs",
                "change": {"after": {}}
            }
        ]
    }
    count(result) == 1
}

test_deny_when_encryption_algorithm_not_approved if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "name": "customer_docs",
                "change": {"after": {}}
            },
            {
                "address": "aws_s3_bucket_server_side_encryption_configuration.customer_docs",
                "type": "aws_s3_bucket_server_side_encryption_configuration",
                "name": "customer_docs",
                "change": {"after": {"rule": [{"apply_server_side_encryption_by_default": [{"sse_algorithm": "DES"}]}]}}
            }
        ]
    }
    count(result) == 1
}

test_pass_when_encryption_present if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "name": "customer_docs",
                "change": {"after": {}}
            },
            {
                "address": "aws_s3_bucket_server_side_encryption_configuration.customer_docs",
                "type": "aws_s3_bucket_server_side_encryption_configuration",
                "name": "customer_docs",
                "change": {"after": {"rule": [{"apply_server_side_encryption_by_default": [{"sse_algorithm": "AES256"}]}]}}
            }
        ]
    }
    count(result) == 0
}