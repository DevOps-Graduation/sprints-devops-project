resource "aws_ebs_volume" "db" {
  availability_zone = var.availability_zone
  size              = var.size
  type              = var.volume_type

  tags = {
    Name = var.name
  }
}
