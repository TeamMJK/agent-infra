variable "kms_alias_name" {
  type    = string
  default = "alias/teammjk-secrets-key"
}

variable "gemini_api_key" {
  description = "Gemini(Google) API Key"
  type        = string
}

variable "db_password_length" {
  description = "DB 비밀번호 길이"
  type        = number
}