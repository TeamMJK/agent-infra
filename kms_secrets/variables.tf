variable "kms_alias_name" {
  type    = string
  default = "alias/teammjk-secrets-key"
}

variable "llm_api_key" {
  description = "LLM API Key"
  type        = string
}

variable "db_password_length" {
  description = "DB 비밀번호 길이"
  type        = number
}