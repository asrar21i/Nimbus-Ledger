package terraform.security

import rego.v1

deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_security_group"
    some ingress in resource.change.after.ingress
    ingress.from_port in {22, 3389}
    some cidr in ingress.cidr_blocks
    cidr == "0.0.0.0/0"
    msg := sprintf("Security group %v has wildcard access for port %v", [resource.address, ingress.from_port])
}