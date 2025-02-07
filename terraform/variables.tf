variable "service_name" {
  description = "The service name"
  type        = string
  default     = "send-mail"
}
variable "send_mail_image" {
  description = "The send mail image"
  type        = string
  default     = ":send-mail.send-mail.5"
}
