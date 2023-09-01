# Create a rnd, for version tag
resource "random_id" "mtc_mode_id" {
  byte_length = 2
  count = var.main_instance_count
}

# Create an instance
resource "aws_instance" "mtc_main" {
    count = var.main_instance_count
    instance_type = var.main_instance_type
    ami = "ami-03a4363a7d864a093"
    key_name = "test_tf"
    vpc_security_group_ids = [aws_security_group.sgrp.id]
    subnet_id = aws_subnet.mtc_public_subnet[count.index].id
    root_block_device {
        volume_size = var.main_vol_size
    }
    
    
    tags = {
        Name = "mtc_main_gal-${random_id.mtc_mode_id[count.index].dec}"
    }
    
    lifecycle {
        create_before_destroy = true
    }
    
    
    provisioner "local-exec" {
        command = "printf '\n${self.public_ip}' >> aws_hosts"
    }
    
    provisioner "local-exec" {
        when = destroy
        command = "sed -i '/^[0-9]/d' aws_hosts" #remove line that begin with numbers from file aws_hosts
    }
}

output "tf_flow_completed" {
    value = {for i in aws_instance.mtc_main[*] : i.tags.Name => "${i.public_ip}:3000"}
}