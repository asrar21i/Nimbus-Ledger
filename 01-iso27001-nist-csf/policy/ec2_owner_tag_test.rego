package terraform.ec2

import rego.v1

test_deny_when_owner_missing if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_instance.app_server",
                "type": "aws_instance",
                "change": {
                    "after": {
                        "tags": {
                            "CostCenter": "eng-42"
                        }
                    }
                }
            }
        ]
    }
    count(result) == 1
}

test_pass_when_owner_tag_present if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_instance.app_server",
                "type": "aws_instance",
                "change": {
                    "after": {
                        "tags": {
                            "Owner": "bob",
                            "CostCenter": "eng-42"
                        }
                    }
                }
            }
        ]
    }
    count(result) == 0
}