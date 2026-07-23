# METADATA
# title: SC-28 - Encryption at Rest (AWS S3)
# description: Every aws_s3_bucket must have a matching server-side encryption configuration.
# custom:
#   control_id: SC-28
#   framework: nist-800-53
#   severity: high
#   remediation: Add aws_s3_bucket_server_side_encryption_configuration referencing the bucket.
package compliance.sc28_aws

import rego.v1

deny contains msg if {
	some bucket in input.configuration.root_module.resources
	bucket.type == "aws_s3_bucket"
	bucket_ref := sprintf("%s.%s", [bucket.type, bucket.name])
	not has_encryption(bucket_ref)
	msg := sprintf("SC-28: aws_s3_bucket.%s has no matching server-side encryption configuration. Add aws_s3_bucket_server_side_encryption_configuration referencing the bucket.", [bucket.name])
}

has_encryption(bucket_ref) if {
	some enc in input.configuration.root_module.resources
	enc.type == "aws_s3_bucket_server_side_encryption_configuration"
	some ref in enc.expressions.bucket.references
	startswith(ref, bucket_ref)
}