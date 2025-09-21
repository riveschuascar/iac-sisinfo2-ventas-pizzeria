# Codigo Terraform para la infraestructura Azure
Este repo continene la infraestructura de un ejemplo introductorio a Azure Data Factory con datos de ventas de una pizzeria

# Requisitos
- Terraform
- Azure CLI

# Uso
* Poner credenciales
```
provider "azurerm" {
    features {}
    # configurar provider para autenticacion via CLI
    client_id = "<ID> del CLIENTE de AZURE"
    ...
}
```

* Inicializar terraform
```terraform init```

* Crear infraestructura
```terraform apply```
* Destruit infraestructura
```terraform destroy```
