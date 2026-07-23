# METADATA
# title: CM-6 - Configuration Settings (AWS required tags)
# description: Taggable resources must carry the four required compliance tags.
# custom:
#   control_id: CM-6
#   framework: nist-800-53
#   severity: medium
#   remediation: Add the missing tags or rely on provider default_tags.
package compliance.cm6_aws

import rego.v1

required := {"Project", "Environment", "ManagedBy", "ComplianceScope"}

taggable_types := {"aws_s3_bucket"}

deny contains msg if {
	some resource in all_resources
	resource.type in taggable_types
	tags := object.get(resource.values, "tags_all", object.get(resource.values, "tags", {}))
	present := {tag | some tag, _ in tags}
	missing := required - present
	count(missing) > 0
	msg := sprintf("CM-6: %s is missing required tags: %v. Add the missing tags or rely on provider default_tags.", [resource.address, missing])
}

all_resources contains resource if {
	some resource in input.planned_values.root_module.resources
}

all_resources contains resource if {
	some child in input.planned_values.root_module.child_modules
	some resource in child.resources
}