data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = var.vpc_id

  tags = {
    Name = "*${var.subnet_name}*"
  }
}

resource "random_id" "index" {
  byte_length = 2
}

locals {
  subnet_ids              = tolist(data.aws_subnet_ids.subnet_ids.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnet_ids.subnet_ids.ids)
  subnet_id               = local.subnet_ids[local.subnet_ids_random_index]

  build_component_name = "${var.identifier}-build-component"
  test_component_name  = "${var.identifier}-test-component"
  configuration_name   = "${var.identifier}-configuration"
  recipe_name          = "${var.identifier}-recipe"
  pipeline_name        = "${var.identifier}-pipeline"
}

data "local_file" "build_file" {
  filename = "${path.root}/${var.build_file_path}"
}

data "local_file" "test_file" {
  filename = "${path.root}/${var.test_file_path}"
}

resource "aws_imagebuilder_component" "build_component" {
  name                  = local.build_component_name
  version               = var.build_component_version
  data                  = data.local_file.build_file.content
  platform              = var.components_platform
  supported_os_versions = var.components_os_versions
  tags                  = merge(var.tags, var.build_component_tags)
}

resource "aws_imagebuilder_component" "test_component" {
  count = var.create_test_component ? 1 : 0

  name                  = local.test_component_name
  version               = var.test_component_version
  data                  = data.local_file.test_file.content
  platform              = var.components_platform
  supported_os_versions = var.components_os_versions
  tags                  = merge(var.tags, var.test_component_tags)
}

resource "aws_imagebuilder_infrastructure_configuration" "configuration" {
  name                          = local.configuration_name
  instance_profile_name         = var.instance_profile_name
  instance_types                = var.instance_types
  key_pair                      = var.key_pair
  subnet_id                     = local.subnet_id
  terminate_instance_on_failure = var.terminate_instance_on_failure
  security_group_ids            = var.security_group_ids
  sns_topic_arn                 = var.sns_topic_arn

  dynamic "logging" {
    for_each = var.enable_logging ? ["1"] : []
    s3_logs {
      s3_bucket_name = var.log_bucket_name
      s3_key_prefix  = var.log_prefix
    }
  }
  tags = merge(var.tags, var.infrastructure_configuration_tags)
}

resource "aws_imagebuilder_image_recipe" "recipe" {
  name         = local.recipe_name
  parent_image = var.managed_parent_image ? "arn:${data.aws_partition.current.partition}:imagebuilder:${data.aws_region.current.name}:aws:image/${var.parent_image_id}" : var.parent_image_id
  version      = var.recipe_version

  block_device_mapping {
    device_name = var.block_device_name

    ebs {
      delete_on_termination = var.ebs_delete_on_termination
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
    }
  }

  component {
    component_arn = aws_imagebuilder_component.build_component.arn
  }
  dynamic "component" {
    for_each      = var.create_test_component ? ["1"] : []
    component_arn = aws_imagebuilder_component.test_component.arn
  }
  tags = merge(var.tags, var.image_recipe_tags)
}

resource "aws_imagebuilder_image_pipeline" "pipeline" {
  name                             = local.pipeline_name
  image_recipe_arn                 = aws_imagebuilder_image_recipe.recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.configuration.arn
  status                           = var.pipeline_status
  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
    timeout_minutes     = var.test_timeout
  }
  schedule {
    schedule_expression                = var.schedule_expression
    pipeline_execution_start_condition = var.pipeline_execution_start_condition
    timezone                           = var.schedule_timezone
  }
  tags = merge(var.tags, var.pipeline_tags)
}
