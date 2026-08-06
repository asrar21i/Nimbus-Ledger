package terraform.s3

import rego.v1

test_deny_when_encryption_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "change": {
                    "after": {
                        "tags": {
                            "Env": "prod"
                        }
                    }
                }
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
                "change": {
                    "after": {
                        "server_side_encryption_configuration": {}
                    }
                }
            }
        ]
    }

    count(result) == 0
}