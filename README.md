# Terraform AWS SQS Module

A Terraform module for managing [Amazon Simple Queue Service (SQS)](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) queues. The module creates a standard or FIFO queue, an optional dead-letter queue wired up through a redrive policy, server-side encryption with either SQS-owned or customer managed KMS keys, and an optional access policy rendered from a local JSON template.

## Features

- **FIFO or Standard Queues**: Creates a FIFO queue by default, automatically appending the required `.fifo` suffix to the queue name, or a standard queue when FIFO is disabled.
- **Dead-Letter Queue**: Optionally creates a companion `<name>_deadletter` queue and attaches a redrive policy with a configurable maximum receive count.
- **Server-Side Encryption**: Encrypts messages with SQS-owned keys by default, or with a customer managed KMS key including a configurable data key reuse period.
- **Message Tuning**: Exposes retention, visibility timeout, maximum message size, delivery delay and long polling wait time.
- **Access Policy**: Optionally attaches a queue policy rendered with `templatefile` from a local JSON file, with the account ID, region, environment and queue name injected as template variables.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Create a FIFO queue with SQS-owned encryption and the default dead-letter queue:

```hcl
module "sqs" {
  source = "git::https://github.com/virsas/terraform-aws-sqs.git?ref=v1.1"

  name        = "vss-application-events"
  accountID   = "123456789012"
  region      = "eu-west-1"
  environment = "production"
}
```

### Advanced Example (Standard Queue, KMS, Tuned Delivery)

Create a standard queue encrypted with a customer managed KMS key, with long polling enabled and a dead-letter queue that accepts messages after five failed receives:

```hcl
module "sqs_standard" {
  source = "git::https://github.com/virsas/terraform-aws-sqs.git?ref=v1.1"

  name        = "vss-application-jobs"
  accountID   = "123456789012"
  region      = "eu-west-1"
  environment = "production"

  fifo = false

  sse_enabled          = false
  kms                  = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  kms_reuse_in_seconds = 600

  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  max_message_size           = 65536
  delay_seconds              = 10
  receive_wait_time_seconds  = 20

  deadletter_enabled                   = true
  deadletter_message_retention_seconds = 1209600
  deadletter_failures_count            = 5
}
```

### Queue Policy Example

Attach an access policy to the queue. The module renders `./json/sqs/vss-application-notifications.json` and exposes the `account`, `region`, `environment` and `name` template variables to it:

```hcl
module "sqs_with_policy" {
  source = "git::https://github.com/virsas/terraform-aws-sqs.git?ref=v1.1"

  name        = "vss-application-notifications"
  accountID   = "123456789012"
  region      = "eu-west-1"
  environment = "production"

  policy_enabled = true
  policy_path    = "./json/sqs"
}
```

### Minimal Queue Example (No Dead-Letter Queue)

Create a standalone standard queue without a dead-letter queue or redrive policy:

```hcl
module "sqs_simple" {
  source = "git::https://github.com/virsas/terraform-aws-sqs.git?ref=v1.1"

  name        = "vss-application-audit"
  accountID   = "123456789012"
  region      = "eu-west-1"
  environment = "production"

  fifo               = false
  deadletter_enabled = false
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.vss_deadletter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the SQS queue. When FIFO is enabled the queue is named `<name>.fifo`, and the dead-letter queue is named `<name>_deadletter`. | `string` | n/a | yes |
| <a name="input_accountID"></a> [accountID](#input\_accountID) | AWS account ID passed to the queue policy template as `account`. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region passed to the queue policy template as `region`. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name passed to the queue policy template as `environment`. | `string` | n/a | yes |
| <a name="input_fifo"></a> [fifo](#input\_fifo) | Enable or disable FIFO mode. When disabled, the queue is created in standard mode. | `bool` | `true` | no |
| <a name="input_sse_enabled"></a> [sse\_enabled](#input\_sse\_enabled) | Enable server-side encryption of message content with SQS-owned encryption keys. | `bool` | `true` | no |
| <a name="input_kms"></a> [kms](#input\_kms) | ARN of the KMS key used to encrypt the queue with a customer managed key. Requires `sse_enabled` to be set to `false`. | `string` | `null` | no |
| <a name="input_kms_reuse_in_seconds"></a> [kms\_reuse\_in\_seconds](#input\_kms\_reuse\_in\_seconds) | Time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. | `number` | `300` | no |
| <a name="input_message_retention_seconds"></a> [message\_retention\_seconds](#input\_message\_retention\_seconds) | Number of seconds Amazon SQS retains a message, from `60` (1 minute) to `1209600` (14 days). | `number` | `345600` | no |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | Time a consumed message stays invisible to other consumers, from `0` to `43200` seconds. | `number` | `30` | no |
| <a name="input_max_message_size"></a> [max\_message\_size](#input\_max\_message\_size) | Limit of how many bytes a message can contain before Amazon SQS rejects it, from `1024` bytes (1 KiB) to `262144` bytes (256 KiB). | `number` | `262144` | no |
| <a name="input_delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | Time before a message becomes available to consumers after being delivered to the queue, from `0` to `900` seconds. | `number` | `0` | no |
| <a name="input_receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#input\_receive\_wait\_time\_seconds) | Long polling wait time for a `ReceiveMessage` call, from `0` to `20` seconds. | `number` | `0` | no |
| <a name="input_deadletter_enabled"></a> [deadletter\_enabled](#input\_deadletter\_enabled) | Enable or disable the dead-letter queue that collects messages received by consumers but never deleted. | `bool` | `true` | no |
| <a name="input_deadletter_message_retention_seconds"></a> [deadletter\_message\_retention\_seconds](#input\_deadletter\_message\_retention\_seconds) | Number of seconds the dead-letter queue retains a message, from `60` to `1209600` seconds (14 days). | `number` | `1209600` | no |
| <a name="input_deadletter_failures_count"></a> [deadletter\_failures\_count](#input\_deadletter\_failures\_count) | Number of times a consumer may receive a message without deleting it before it is moved to the dead-letter queue. | `number` | `3` | no |
| <a name="input_policy_enabled"></a> [policy\_enabled](#input\_policy\_enabled) | Enable or disable the access policy attached to this queue. | `bool` | `false` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | Path to the directory holding the policy templates. The module reads `<policy_path>/<name>.json`. | `string` | `"./json/sqs"` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the SQS queue. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the SQS queue. |
| <a name="output_url"></a> [url](#output\_url) | The URL of the SQS queue. |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
