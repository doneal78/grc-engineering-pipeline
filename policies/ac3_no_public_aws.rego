# METADATA
# title: AC-3 - Access Enforcement (AWS S3 public access block)
# description: Every aws_s3_bucket must have a public access block with all four flags true.
# custom:
#   control_id: AC-3
#   framework: nist-800-53
#   severity: critical
#   remediation: Add aws_s3_bucket_public_access_block referencing the bucket, all four flags true.
package compliance.ac3_aws

import rego.v1

deny contains msg if {
	some bucket in input.configuration.root_module.resources
	bucket.type == "aws_s3_bucket"
	bucket_ref := sprintf("%s.%s", [bucket.type, bucket.name])
	not has_complete_pab(bucket_ref)
	msg := sprintf("AC-3: aws_s3_bucket.%s has no public access block with all four flags set to true. Add aws_s3_bucket_public_access_block referencing the bucket, all four flags true.", [bucket.name])
}

has_complete_pab(bucket_ref) if {
	some pab_cfg in input.configuration.root_module.resources
	pab_cfg.type == "aws_s3_bucket_public_access_block"
	some ref in pab_cfg.expressions.bucket.references
	startswith(ref, bucket_ref)

	pab_address := sprintf("%s.%s", [pab_cfg.type, pab_cfg.name])
	some pv in input.planned_values.root_module.resources
	pv.address == pab_address
	pv.values.block_public_acls == true
	pv.values.block_public_policy == true
	pv.values.ignore_public_acls == true
	pv.values.restrict_public_buckets == true
}