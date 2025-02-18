
# === compute/main.tf ====

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "random_id" "pht_node_id" {
  count = var.instance_count

  byte_length = 2
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "mtc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "pht_node" {
  count = var.instance_count # 1

  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type

  key_name = var.key_name

  user_data = templatefile(var.user_data_path,
    {
      nodename    = "pht-node-${random_id.pht_node_id[count.index].dec}"
      dbname      = var.dbname
      db_endpoint = var.db_endpoint
      dbuser      = var.dbuser
      dbpass      = var.dbpass
    }
  )

  subnet_id              = var.public_subnets[count.index]
  vpc_security_group_ids = var.public_sg

  root_block_device {
    volume_size = var.vol_size # 10
  }

  tags = {
    Name = "pht-node-${random_id.pht_node_id[count.index].dec}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
    }
    script = "${path.root}/scripts/delay.sh"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/scripts/scp-script.tftpl",
      {
        private_key_path = var.private_key_path
        nodeip           = self.public_ip
        nodename         = self.tags.Name
        k3s_path         = "${path.cwd}/../"
      }
    )
  }
  provisioner "local-exec" {
    when = destroy

    command = "rm -f ${path.cwd}/../k3s-${self.tags.Name}.yaml"
  }
}

resource "aws_lb_target_group_attachment" "pht_tg_attach" {
  count = var.instance_count

  target_group_arn = var.lb_tg_arn
  target_id        = aws_instance.pht_node[count.index].id

  port = var.tg_port
}

