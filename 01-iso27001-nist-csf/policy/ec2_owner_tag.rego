package terraform.ec2

import rego.v1

deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_instance"
    not resource.change.after.tags.Owner
    msg := sprintf("EC2 instance %v is missing an Owner tag", [resource.address])
}