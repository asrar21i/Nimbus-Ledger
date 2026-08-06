package terraform.rds

import rego.v1


test_deny_when_storage_not_encrypted if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_db_instance.main",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "storage_encrypted": false,
                        "publicly_accessible": false
                    }
                }

            }
        ]
    }
    count(result) == 1
}

test_deny_when_public_accessible if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_db_instance.main",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "storage_encrypted": true,
                        "publicly_accessible": true
                    }
                }

            }
        ]
    }
    count(result) == 1
}

test_allow_when_storage_encrypted_and_no_public_access if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_db_instance.main",
                "type": "aws_db_instance",
                "change": {
                    "after": {
                        "storage_encrypted": true,
                        "publicly_accessible": false
                    }
                }
            }
        ]
    }
    count(result) == 0
}