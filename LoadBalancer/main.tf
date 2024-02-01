resource "aws_s3_bucket" "nginx-alb-logs" {
  bucket = var.alblogs3
  tags = {
    Name        = "${var.alblogs3}"
  }
}

resource "aws_s3_bucket_policy" "alb_access_logs_policy" {
  bucket = aws_s3_bucket.nginx-alb-logs.bucket

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::114774131450:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.alblogs3}/*"
    }
  ]
})
}

resource "aws_security_group" "wlo-terraform-alb-sg" {
  name   = var.alb-sg-name
  vpc_id = var.vpcid
  
  dynamic "ingress" {
    for_each = var.alb-ingress-port
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "terraform-alb" {
  name               = var.alb-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wlo-terraform-alb-sg.id]
  subnets            = [for subnet in var.public-subnetid : subnet]
 

  enable_deletion_protection = false

     access_logs {
      bucket  = aws_s3_bucket.nginx-alb-logs.id
      enabled = true
    }

  tags = {
    Environment = "${var.alb-name}"
  }
  depends_on = [ aws_security_group.wlo-terraform-alb-sg ]
}

resource "aws_lb_target_group" "tg80" {
  name     = "wlo-terraform-alb-tg-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpcid
}

resource "aws_lb_target_group_attachment" "tg-attach80" {
  target_group_arn = aws_lb_target_group.tg80.arn
  # for_each         = toset(var.instance-id)
  # target_id        = each.value
  count = length(var.instance-id)
  target_id = var.instance-id[count.index]
  port             = 80
  depends_on = [ aws_lb_target_group.tg80 ]
}


resource "aws_lb_listener" "listen443" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg80.arn
  }
  depends_on = [ aws_lb.terraform-alb]
}


resource "aws_lb_listener_certificate" "albcertificate" {
  listener_arn    = aws_lb_listener.listen443.arn
  certificate_arn = var.certificate

  depends_on = [ aws_lb_target_group.tg80 ]
}

resource "aws_lb_listener" "listen80" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {  
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [ aws_lb.terraform-alb ]
}

