package terraform.tagging

import rego.v1

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