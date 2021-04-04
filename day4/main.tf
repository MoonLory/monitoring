provider "aws" {
    region = "us-east-2"
    shared_credentials_file = "C:\\Users\\Andrei_Hryshkin\\.aws\\credentials"
}

resource "aws_instance" "server" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.name_key

    connection {
        type = "ssh"
        user = "centos"
        private_key = file("C:\\Users\\Andrei_Hryshkin\\tasks\\monitoring\\mon-key.pem")
        host = self.public_ip
    }

    provisioner "file" {
        source = "install_server.sh"
        destination = "/tmp/install_server.sh"
    }

    provisioner "file" {
        source = "inn_db.sh"
        destination = "/tmp/inn_db.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/*sh",
          "cd /tmp",
          "./install_server.sh",
    ]
    }
}

resource "aws_instance" "client" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.name_key

    connection {
        type = "ssh"
        user = "centos"
        private_key = file("C:\\Users\\Andrei_Hryshkin\\tasks\\monitoring\\mon-key.pem")
        host = self.public_ip
    }

    provisioner "file" {
        source = "install_agent.sh"
        destination = "/tmp/install_agent.sh"
    }
    
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/*sh",
            "cd /tmp",
            "./install_agent.sh ${aws_instance.server.public_ip}"
        ] 
    }
}
