# create two apache web servers in the qa environment
resource "azurerm_windows_virtual_machine" "apache_vm" {
  count               = 2
  name                = "apache-vm-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.apache_nic[count.index].id
  ]

  os_disk {
    name                 = "apache-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

# 4 windows web app servers
resource "azurerm_windows_virtual_machine" "webapp_vm" {
  count               = 2
  name                = "webapp-vm-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  # attach each VM to its own NIC
  network_interface_ids = [
    azurerm_network_interface.webapp_nic[count.index].id
  ]

  os_disk {
    name                 = "webapp-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

}
# Triggering GitHub Actions run