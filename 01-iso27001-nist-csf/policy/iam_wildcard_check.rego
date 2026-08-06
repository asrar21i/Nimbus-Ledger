package terraform.iam

import rego.v1

action_matches(statement, action_name) if {
    statement.Action == action_name
}
action_matches(statement, action_name) if {
    some action in statement.Action
    action == action_name
}
resource_matches(statement, resource_name) if {
    statement.Resource == resource_name
}
resource_matches(statement, resource_name) if {
    some resource in statement.Resource
    resource == resource_name
}
deny contains msg if {
    some resource in input.resource_changes
    resource.type == "aws_iam_policy"
    parsed_policy := json.unmarshal(resource.change.after.policy)
    some statement in parsed_policy.Statement
    action_matches(statement, "iam:*")
    resource_matches(statement, "*")
    msg := sprintf(
        "IAM policy %v grants unrestricted iam:* access",
        [resource.address]
    )
}