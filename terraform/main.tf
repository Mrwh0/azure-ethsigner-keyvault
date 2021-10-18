terraform {
  required_providers {
    azurerm = {}
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.4.0"
    }
    random  = {}
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {}

locals {
  deployment_name = "ethsigner"
  location        = "eastus"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.deployment_name}-${local.location}"
  location = local.location
}

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
  service_principal_id = "${azuread_service_principal.this.id}"
  value                = random_string.this.result
  end_date             = "2023-01-01T00:00:00Z"
}

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
      "ETHSIGNER_CHAIN_ID"                        = "172"
      "ETHSIGNER_HTTP_CORS_ORIGINS"               = "*"
      "ETHSIGNER_HTTP_LISTEN_HOST"                = "0.0.0.0"
      "ETHSIGNER_DOWNSTREAM_HTTP_HOST"            = "rpc.latam-blockchain.com"
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
