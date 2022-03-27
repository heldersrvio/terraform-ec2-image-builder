variable "identifier" {
  type        = string
  description = "A name to identify the AMI"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC to be used for the image pipeline"
  default     = null
}

variable "subnet_name" {
  type        = string
  description = "A name or part of a name that identifies the subnet, or a group of subnet. Example: 'private' will match 'my-private-subnet', 'private' and 'private-subnet-1'"
  default     = null
}

variable "build_file_path" {
  type        = string
  description = "The path to the YAML build file"
  default     = null
}

variable "test_file_path" {
  type        = string
  description = "The path to the YAML test file"
  default     = null
}

variable "create_test_component" {
  type        = bool
  description = "If a test component should be created"
  default     = true
}

variable "build_component_version" {
  type        = string
  description = "The version of the image build component of type 'build'"
  default     = "1.0.0"
}

variable "test_component_version" {
  type        = string
  description = "The version of the image build component of type 'test'"
  default     = "1.0.0"
}

variable "components_platform" {
  type        = string
  description = "The platform on which the components will be run"
  default     = "Linux"
}

variable "components_os_versions" {
  type        = list(string)
  description = "List of OS versions the components support"
  default     = ["Amazon Linux 2"]
}

variable "instance_types" {
  type        = list(string)
  description = "The EC2 instance types"
  default     = ["t2.micro"]
}

variable "key_pair" {
  type        = string
  description = "The key pair that can be used to SSH into the instances"
  default     = null
}

variable "terminate_instance_on_failure" {
  type        = bool
  description = "If the instances should be terminated in case the pipeline failed"
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security groups"
  default     = []
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN for the SNS topic"
  default     = null
}

variable "enable_logging" {
  type        = bool
  description = "If logging should be enabled during the pipeline execution"
  default     = false
}

variable "log_bucket_name" {
  type        = string
  description = "The name of the bucket where logs will go"
  default     = null
}

variable "log_prefix" {
  type        = string
  description = "A prefix to attach to the logs"
  default     = null
}

variable "managed_parent_image" {
  type        = bool
  description = "Whether the parent image of the AMI is managed by Image Builder as well"
  default     = true
}

variable "parent_image_id" {
  type        = string
  description = "The ID of the parent AMI"
  default     = "amazon-linux-2-x86/x.x.x"
}

variable "recipe_version" {
  type        = string
  description = "The version of the image recipe"
}

variable "block_device_name" {
  type        = string
  description = "The name of the block device"
  default     = "/dev/xvda"
}

variable "ebs_delete_on_termination" {
  type        = bool
  description = "Whether the created EBS volumes should be deleted when the instances are terminated"
  default     = true
}

variable "ebs_volume_size" {
  type        = number
  description = "The size (in GB) of the EBS volume"
  default     = 8
}

variable "ebs_volume_type" {
  type        = string
  description = "The type of the EBS volume"
  default     = "gp2"
}

variable "pipeline_status" {
  type        = string
  description = "'enabled' or 'disabled'"
  default     = "enabled"
}

variable "image_tests_enabled" {
  type        = bool
  description = "Whether image tests are enabled during the pipeline execution"
  default     = true
}

variable "test_timeout" {
  type        = number
  description = "Number of minutes before the tests timeout"
  default     = null
}

variable "schedule_expression" {
  type        = string
  description = "The expression (cron or rate) according to which the pipeline will be run"
  default     = "cron(0 * * ? *)"
}

variable "pipeline_execution_start_condition" {
  type        = string
  description = "The condition that will trigger the pipeline. 'EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE' or 'EXPRESSION_MATCH_ONLY'"
  default     = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
}

variable "schedule_timezone" {
  type        = string
  description = "The timezone according to which the schedule_expression will be evaluated. Follows the IANA timezone format"
  default     = "Etc/UTC"
}

// TODO: tags
