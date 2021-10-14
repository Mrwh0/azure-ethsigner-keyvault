resource "azurerm_key_vault" "this" {
  name                = "kv-${local.deployment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  access_policy {
    key_permissions = ["Create", "List", "Get", "Delete", "Purge"]
    object_id       = data.azurerm_client_config.current.object_id
    tenant_id       = data.azurerm_client_config.current.tenant_id
  }

  access_policy {
    key_permissions = ["Get", "Sign"]
    object_id       = azuread_service_principal.this.object_id
    tenant_id       = data.azurerm_client_config.current.tenant_id
  }
}

resource "azurerm_key_vault_key" "this" {
  name         = "key-${local.deployment_name}"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "EC-HSM"
  curve        = "SECP256K1"

  key_opts = [
    "sign",
    "verify"
  ]
}