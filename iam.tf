resource "aws_iam_instance_profile" "ansible" {
  name = "ansible-profile-role"
  role = aws_iam_role.ansible_role.name
}
resource "aws_iam_role" "ansible_role" {
  name = "ansible-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ansible_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role      = aws_iam_role.ansible_role.name
}
resource "aws_iam_role_policy_attachment" "autoscaling_full_access" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}
resource "aws_iam_role_policy_attachment" "rds_full_access" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}