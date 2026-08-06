package terraform.s3

import rego.v1

required_public_block_settings := {
    "block_public_acls",
    "block_public_policy",
    "ignore_public_acls",
    "restrict_public_buckets",
}
deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_s3_bucket_public_access_block"
    after := resource.change.after
    some field in required_public_block_settings
    not after[field]
    msg := sprintf(
        "S3 bucket %v has %v disabled",
        [resource.address, field]
    )
}