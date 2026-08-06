package terraform.security

import rego.v1

test_deny_when_ssh_open_to_world if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_security_group.app_sg",
                "type": "aws_security_group",
                "change": {
                    "after": {
                        "ingress": [
                            {
                                "from_port": 22,
                                "cidr_blocks": ["0.0.0.0/0"]
                            }
                        ]
                    }
                }
            }
        ]
    }
    count(result) == 1
}
test_deny_when_rdp_open_to_world if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_security_group.app_sg",
                "type": "aws_security_group",
                "change": {
                    "after": {
                        "ingress": [
                            {
                                "from_port": 3389,
                                "cidr_blocks": ["0.0.0.0/0"]
                            }
                        ]
                    }
                }
            }
        ]
    }
    count(result) == 1
}
test_pass_when_only_internal_access if {
    result := deny with input as {
        "resource_changes": [
            {
                "address": "aws_security_group.app_sg",
                "type": "aws_security_group",
                "change": {
                    "after": {
                        "ingress": [
                            {
                                "from_port": 443,
                                "cidr_blocks": ["10.0.0.0/16"]
                            }
                        ]
                    }
                }
            }
        ]
    }
    count(result) == 0
}

