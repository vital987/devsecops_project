variable "user" {
  type    = string
  default = "azureuser"
}
variable "location" {
  type    = string
  default = "Central India"
}
variable "rgname" {
  type    = string
  default = "cicd_pipeline"
}
variable "psql_passwd" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.psql_passwd) > 8
    error_message = "Password uncomplied with DB's password policy."
  }
}
