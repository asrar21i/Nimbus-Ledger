package terraform.tagging
import rego.v1

test_deny_when_dataclassification_missing if {
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

test_pass_when_dataclassification_present if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_db_instance.main",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "tags": {
                            "DataClassification": "Confidential"
                        }
                    }
                }
            }
        ]
    }
    count(result) == 0
}