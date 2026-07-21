variable "name" {
  description = "Name of the SQS queue. If FIFO is enabled, it will by named name.fifo automatically. If deadletter is enabled, the queue for the deadletters will be named name_deadletter."
  type        = string
}
variable "accountID" {
  description = "AWS Account ID"
  type        = string
}
variable "region" {
  description = "AWS Region"
  type        = string
}
variable "environment" {
  description = "AWS Environment"
  type        = string
}
variable "fifo" {
  description = "Enable / Disable FIFO mode. Defaults to true. If disabled, the queue is in standard mode."
  type        = bool
  default     = true
}
variable "sse_enabled" {
  description = "Enable server-side encryption (SSE) of message content with SQS-owned encryption keys. Defaults to true."
  type        = bool
  default     = true
}
variable "kms" {
  description = "ARN of KMS key, if kms should be encrypted with own key. By default, this value is null. This requires sse_enabled to be set to false."
  type        = string
  default     = null
}
variable "kms_reuse_in_seconds" {
  description = "Time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. Defaults to 300"
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. From 60 (1 minute) to 1209600 (14 days). Defaults to 4 days - 345600 seconds"
  type        = number
  default     = 345600
}
variable "visibility_timeout_seconds" {
  description = "The timeout for consumed message not to be visible to other consumers. From 0 to 43200 seconds. Defaults to 30."
  type        = number
  default     = 30
}
variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. From 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). Defaults to 262144 (256 KiB)"
  type        = number
  default     = 262144
}
variable "delay_seconds" {
  description = "The time before the message is available to consumers after being delivered to the queue. From 0 to 900 seconds. Defaults to 0"
  type        = number
  default     = 0
}
variable "receive_wait_time_seconds" {
  description = "Wait time for a ReceiveMessage call. From 0 to 20 seconds. Defaults to 0."
  type        = number
  default     = 0
}
variable "deadletter_enabled" {
  description = "Enable / Disable deadletter queue. Queue with messages that were received by consumere, but never deleted. Defaults to true."
  type        = bool
  default     = true
}
variable "deadletter_message_retention_seconds" {
  description = "The number of seconds Deadletter queue will retain a message from 60 to 1209600 secconds. Defaults to 1209600 (14 days)."
  type        = number
  default     = 1209600
}
variable "deadletter_failures_count" {
  description = "The number of times a consumer tries receiving a message from a queue without deleting it before being moved to the dead-letter queue. Defaults to 3"
  type        = number
  default     = 3
}
variable "policy_enabled" {
  description = "Enable/Disable access policy for this queue. Defaults to False"
  type        = bool
  default     = false
}
variable "policy_path" {
  description = "Path to directory with all the policies. By default ./json/sqs/NAME.json where the name is the name of the bucket"
  type        = string
  default     = "./json/sqs"
}