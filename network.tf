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
# create a public IP address for the load balancer
# this will be used to access the Apache web server
resource "azurerm_public_ip" "apache_lb_pip" {
    name                = "ap-lb-pip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}
resource "azurerm_lb" "apache_lb" {
  name                = "ap-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "ap-lb-fe"
    public_ip_address_id = azurerm_public_ip.apache_lb_pip.id
  }
}
# Backend pool for the public load balancer
resource "azurerm_lb_backend_address_pool" "apache_lb_backend_pool" {
  name            = "ap-lb-backend-pool"
  loadbalancer_id = azurerm_lb.apache_lb.id
}
# Health probe for public LB (port80)
resource "azurerm_lb_probe" "apache_lb_probe" {
  name                = "apache-lb-probe"
  loadbalancer_id    = azurerm_lb.apache_lb.id
  protocol           = "Http"
  port               = 80
  interval_in_seconds = 15
  number_of_probes   = 2
}
#Load balancing rule for public LB (port80)
resource "azurerm_lb_rule" "apache_lb_rule" {
  name                = "apache-lb-rule"
  loadbalancer_id    = azurerm_lb.apache_lb.id
  protocol           = "Tcp"
  frontend_port      = 80
  backend_port       = 80
  frontend_ip_configuration_name = "ap-lb-fe"
  probe_id          = azurerm_lb_probe.apache_lb_probe.id
}
# Create 2 NICs and 2 Apache VMs
resource "azurerm_network_interface" "apache_nic" {
  count               = 2
  name                = "apache-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
      name                          = "apache-ip-config-${count.index}"
      subnet_id                     = azurerm_subnet.subnet.id
      private_ip_address_allocation = "Dynamic"
  }
}
# Internal Load Balancer (private-facing)
resource "azurerm_lb" "internal_lb" {
  name                = "internal-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                          = "internal-lb-fe"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Backend pool for internal load balancer
resource "azurerm_lb_backend_address_pool" "webapp_backend_pool" {
  name                = "webapp-bepool"
  loadbalancer_id     = azurerm_lb.internal_lb.id
}

# Health probe for internal LB (port 80)
resource "azurerm_lb_probe" "webapp_probe" {
  name                = "webapp-health-probe"
  loadbalancer_id     = azurerm_lb.internal_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load balancing rule (internal port 80)
resource "azurerm_lb_rule" "webapp_lb_rule" {
  name                           = "webapp-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  loadbalancer_id                = azurerm_lb.internal_lb.id
  frontend_ip_configuration_name = "internal-lb-fe"
  probe_id                       = azurerm_lb_probe.webapp_probe.id
}
