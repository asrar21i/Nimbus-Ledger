package terraform.rds

import rego.v1

deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_db_instance"
    not resource.change.after.storage_encrypted
    msg := sprintf("%v storage is not encrypted",[resource.address])
}

deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_db_instance"
    resource.change.after.publicly_accessible 
    msg := sprintf("%v is publicly accessible",[resource.address])
}