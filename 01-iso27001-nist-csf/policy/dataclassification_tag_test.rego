package terraform.tagging

import rego.v1

# RDS: missing DataClassification must be denied
test_deny_when_rds_dataclassification_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_db_instance.main",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice"
                        }
                    }
                }
            }
        ]
    }

    count(result) == 1
}


# Destroy: change.after is null, so tagging policy is skipped
test_destroy_action if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "change": {
                    "after": null
                }
            }
        ]
    }

    count(result) == 0
}


# RDS: valid DataClassification must pass
test_pass_when_rds_dataclassification_present if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_db_instance.main",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice",
                            "DataClassification": "Confidential"
                        }
                    }
                }
            }
        ]
    }

    count(result) == 0
}


# EC2: missing DataClassification must be denied
test_deny_when_ec2_dataclassification_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_instance.app_server",
                "type": "aws_instance",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice"
                        }
                    }
                }
            }
        ]
    }

    count(result) == 1
}


# EC2: valid DataClassification must pass
test_pass_when_ec2_dataclassification_present if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_instance.app_server",
                "type": "aws_instance",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice",
                            "DataClassification": "Confidential"
                        }
                    }
                }
            }
        ]
    }

    count(result) == 0
}


# S3: missing DataClassification must be denied
test_deny_when_s3_dataclassification_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice"
                        }
                    }
                }
            }
        ]
    }

    count(result) == 1
}


# S3: valid DataClassification must pass
test_pass_when_s3_dataclassification_present if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice",
                            "DataClassification": "Confidential"
                        }
                    }
                }
            }
        ]
    }

    count(result) == 0
}


# Exact-message test: missing S3 DataClassification
test_deny_message_when_s3_dataclassification_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice"
                        }
                    }
                }
            }
        ]
    }

    result == {
        "Resource aws_s3_bucket.customer_docs is missing DataClassification tag"
    }
}


# Exact-message test: invalid S3 DataClassification
test_deny_message_when_s3_dataclassification_invalid if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.customer_docs",
                "type": "aws_s3_bucket",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "alice",
                            "DataClassification": "xyz"
                        }
                    }
                }
            }
        ]
    }

    result == {
        "Resource aws_s3_bucket.customer_docs has invalid DataClassification tag"
    }
}