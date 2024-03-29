##Provider
provider "vsphere" {

  user           = var.user
  password       = var.password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

##Data

data "vsphere_datacenter" "dc" {
  name = var.name_dc
}

# If you don't have any resource pools, put "/Resources" after cluster name
data "vsphere_resource_pool" "pool" {
  name          = var.name_rp
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = var.name_vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = var.name_vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Cluster
data "vsphere_compute_cluster" "cluster" {
  name          = var.name_vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "VM_ubutnu_template"
  datacenter_id = data.vsphere_datacenter.dc.id
}



##vSphere VMs

# Set vm parameters
resource "vsphere_virtual_machine" "demoo" {
  count="1"
  name ="test-vm-${count.index + 1}"
  //name             = "vm_pfe"
  num_cpus         = 4
  memory           = 4096
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  // ip_address


  network_interface {
    network_id = data.vsphere_network.network.id
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1

  disk {
    label            = "disk0"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
  }


  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

customize {
  linux_options {
    host_name = "terraform-test"
    domain    = "cloud-temple.lan"
  }


network_interface {
ipv4_address = "10.203.18.${13 + count.index}"
  ipv4_netmask = 24
}

ipv4_gateway = "10.203.18.254"
}
  }


/*extra_config = {
   "guestinfo.userdata"  = base64encode(file("../Scripts/userdata.yaml"))
   "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata" = base64encode(file("../Scripts/metadata.yaml"))
   "guestinfo.metadata.encoding" = "base64"

 }*/

  }





