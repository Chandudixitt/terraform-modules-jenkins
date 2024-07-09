terraform {
  backend "azurerm" {
    resource_group_name   = "demosatatergnew"
    storage_account_name  = "demostatesa1234"
    container_name        = "terraform-state-cont"
    key                   = "terraform.tfstate"
    use_msi               = true
    client_id             = "59a6d3a3-4d0c-46d1-84a9-de714a8b6345"
    access_key            = "dKQwZYdPUTSWcj6kqyhe4GNLGadYFHWgv0fIpgbUXUL6BKk4ZyRIyCjdj5M2UhYmune02QyBf3kG+AStIanRJA=="
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

module "resource_group" {
  source              = "./modules/resource_group"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "virtual_network" {
  source                = "./modules/virtual_network"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  vnet_name             = var.vnet_name
  vnet_address_space    = var.vnet_address_space
  tags                  = var.tags
}

module "subnet" {
  source                = "./modules/subnet"
  resource_group_name   = module.resource_group.name
  virtual_network_name  = module.virtual_network.name
  subnet_name           = var.subnet_name
  subnet_address_prefix = var.subnet_address_prefix
}

module "public_ip" {
  source                = "./modules/public_ip"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  public_ip_name        = var.public_ip_name
  tags                  = var.tags
}

module "network_security_group" {
  source                = "./modules/network_security_group"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  nsg_name              = var.nsg_name
  inbound_rules         = var.inbound_rules
  outbound_rules        = var.outbound_rules
  tags                  = var.tags
}

module "network_interface" {
  source                = "./modules/network_interface"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  nic_name              = var.nic_name
  subnet_id             = module.subnet.id
  public_ip_id          = module.public_ip.id
  nsg_id                = module.network_security_group.id
  network_interface_id  = module.network_interface.id
  tags                  = var.tags
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

module "virtual_machine" {
  source                = "./modules/virtual_machine"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  vm_name               = var.vm_name
  vm_size               = var.vm_size
  admin_username        = var.admin_username
  admin_ssh_key         = tls_private_key.example.public_key_openssh
  subnet_id             = module.subnet.id
  os_disk_name          = var.os_disk_name
  os_disk_size_gb       = var.os_disk_size_gb
  network_interface_id  = module.network_interface.id
  tags                  = var.tags
}

output "tls_private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

