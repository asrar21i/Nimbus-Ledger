package terraform.s3

import rego.v1

deny contains msg if {
    some bucket in input.resource_changes
    bucket.type == "aws_s3_bucket"

    not encryption_resource_exists(bucket.name)

    msg := sprintf(
        "S3 bucket %v does not have server-side encryption configured",
        [bucket.address],
    )
}

deny contains msg if {
    some encryption in input.resource_changes
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"

    some rule in encryption.change.after.rule
    some sse_default in rule.apply_server_side_encryption_by_default

    algorithm := sse_default.sse_algorithm

    not approved_encryption_algorithm(algorithm)

    msg := sprintf(
        "S3 bucket encryption resource %v uses an unapproved server-side encryption algorithm: %v",
        [encryption.address, algorithm],
    )
}

encryption_resource_exists(bucket_name) if {
    some encryption in input.resource_changes
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"
    encryption.name == bucket_name
}

approved_encryption_algorithm("AES256")
approved_encryption_algorithm("aws:kms")