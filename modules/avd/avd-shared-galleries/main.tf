resource "azurerm_shared_image_gallery" "sig" {
	name                = "${var.sig_name}"
	resource_group_name = "${var.resource_group_name}"
	location            = "${var.location}"
	description         = "Shared images"

	tags				= var.tags
}

#Creates image definition
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image
resource "azurerm_shared_image" "shared-image" {
	name                = "avd-image"
	gallery_name        = azurerm_shared_image_gallery.sig.name
	resource_group_name = "${var.resource_group_name}"
	location            = "${var.location}"
	os_type             = "Windows"

	identifier {
		publisher = "MicrosoftWindowsDesktop"
		offer     = "office-365"
		sku       = "20h2-evd-o365pp"
	}
}