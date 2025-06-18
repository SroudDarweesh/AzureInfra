# creating a resource group in Azure
resource "azurerm_resource_group" "rg" {
  name     = "qa-rg1"
  location = "East US"

}
# creating a virtual network in Azure
resource "azurerm_virtual_network" "vnet" {
  name                = "qa-vnet1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
# create a subnet in the qa environment
resource "azurerm_subnet" "subnet" {
  name                 = "qa-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
#trigger apply