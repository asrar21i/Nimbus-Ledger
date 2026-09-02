package terraform.iam

import rego.v1

test_deny_when_iam_wildcard if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_iam_policy.admin_policy",
                "type": "aws_iam_policy",
                "change": {
                    "after": {
                        "policy": "{\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"iam:*\",\"Resource\":\"*\"}]}"
                    }
                }
            }
        ]
    }

    count(result) == 1
}

test_pass_when_iam_scoped if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_iam_policy.admin_policy",
                "type": "aws_iam_policy",
                "change": {
                    "after": {
                        "policy": "{\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"iam:GetUser\",\"Resource\":\"arn:aws:iam::123456789012:user/alice\"}]}"
                    }
                }
            }
        ]
    }

    count(result) == 0
}