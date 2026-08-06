package terraform.tagging

import rego.v1

deny contains msg if {
    some resource in input.resource_changes
    resource.type in {"aws_s3_bucket", "aws_db_instance"}
    not resource.change.after.tags.DataClassification
    msg := sprintf("Resource %v is missing a DataClassification tag", [resource.address])
}