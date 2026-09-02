package terraform.tagging

import rego.v1

deny contains msg if {
    some resource in input.resource_changes
    resource.type in {"aws_s3_bucket", "aws_db_instance", "aws_instance"}
    resource.change.after != null
    not resource.change.after.tags.DataClassification
    msg := sprintf("Resource %v is missing DataClassification tag", [resource.address])
}




deny contains msg if {
    some resource in input.resource_changes
    resource.type in {"aws_s3_bucket", "aws_db_instance", "aws_instance"}
    resource.change.after != null
    "DataClassification" in object.keys(resource.change.after.tags)
    not resource.change.after.tags.DataClassification in {"Public", "Private", "Confidential", "Restricted"}
    msg := sprintf("Resource %v has invalid DataClassification tag", [resource.address])
} 





