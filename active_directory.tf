resource "azuread_application" "this" {
  display_name = local.deployment_name
}

resource "azuread_service_principal" "this" {
  application_id = azuread_application.this.application_id
}

resource "random_string" "this" {
  length  = 16
  special = true
  upper   = false
}

resource "azuread_service_principal_password" "this" {
  service_principal_id = azuread_service_principal.this.id
  value                = random_string.this.result
  end_date             = "2022-01-01T00:00:00Z"
}