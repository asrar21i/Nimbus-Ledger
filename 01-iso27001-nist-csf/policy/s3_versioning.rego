package terraform.s3

import rego.v1

deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_s3_bucket_versioning"
    resource.change.after.versioning_configuration[0].status != "Enabled"
    msg := sprintf("S3 bucket versioning resource %v does not have versioning enabled", [resource.address])
}

