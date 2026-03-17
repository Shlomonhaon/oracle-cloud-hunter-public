terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = "YOUR_TENANCY_OCID"
  user_ocid        = "YOUR_USER_OCID"
  private_key_path = "/app/config/oci_api_key.pem"
  fingerprint      = "YOUR_FINGERPRINT"
  region           = "YOUR_REGION"  # לדוגמה: il-jerusalem-1
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = "YOUR_TENANCY_OCID"
}

data "oci_core_images" "ubuntu" {
  compartment_id           = "YOUR_TENANCY_OCID"
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "arm_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = "YOUR_TENANCY_OCID"
  display_name        = "oracle-hunter-instance"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  create_vnic_details {
    subnet_id        = "YOUR_SUBNET_OCID"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = ""  # אופציונלי: הוסף SSH public key כאן
  }
}
