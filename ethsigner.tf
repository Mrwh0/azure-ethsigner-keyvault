resource "azurerm_container_group" "this" {
  name                = "aci-${local.deployment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "public"
  os_type             = "Linux"

  container {
    name   = local.deployment_name
    image  = "pegasyseng/ethsigner:21.3.0"
    cpu    = "0.5"
    memory = "1.5"

    commands = ["/opt/ethsigner/bin/ethsigner", "azure-signer"]

    ports {
      port     = 8545
      protocol = "TCP"
    }

    volume {
      name       = "client-secrets"
      mount_path = "/mnt/secrets"
      secret = {
        "ethsigner" = base64encode(azuread_service_principal_password.this.value)
      }
    }

    environment_variables = {
      "ETHSIGNER_CHAIN_ID"                        = "1"
      "ETHSIGNER_HTTP_CORS_ORIGINS"               = "*"
      "ETHSIGNER_DOWNSTREAM_HTTP_HOST"            = "cloudflare-eth.com"
      "ETHSIGNER_DOWNSTREAM_HTTP_PORT"            = "443"
      "ETHSIGNER_DOWNSTREAM_HTTP_TLS_ENABLED"     = "true"
      "ETHSIGNER_AZURE_SIGNER_CLIENT_ID"          = azuread_application.this.application_id
      "ETHSIGNER_AZURE_SIGNER_CLIENT_SECRET_PATH" = "/mnt/secrets/ethsigner"
      "ETHSIGNER_AZURE_SIGNER_KEY_NAME"           = azurerm_key_vault_key.this.name
      "ETHSIGNER_AZURE_SIGNER_KEY_VERSION"        = azurerm_key_vault_key.this.version
      "ETHSIGNER_AZURE_SIGNER_KEY_VAULT_NAME"     = azurerm_key_vault.this.name
      "ETHSIGNER_AZURE_SIGNER_TENANT_ID"          = azurerm_key_vault.this.tenant_id
    }
  }
}