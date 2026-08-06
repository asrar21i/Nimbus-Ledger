package terraform.s3

import rego.v1

test_deny_when_versioning_disabled if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_versioning.customer_docs",
                "type": "aws_s3_bucket_versioning",
                "change": {
                    "after": {
                        "versioning_configuration":[
                    {"status": "Suspended"}
                        ]
                    }
                }
            }
        ]
    }
    count(result) == 1
}

test_pass_when_versioning_enabled if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_versioning.customer_docs",
                "type": "aws_s3_bucket_versioning",
                "change": {
                    "after":{
                        "versioning_configuration":[
                            {"status": "Enabled"}
                        ]
                    }
                }
            }
        ]
    }
    count(result) == 0 
}