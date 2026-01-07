# resource "aws_lb" "ncc" {
#   name                       = lower(var.name_prefix)
#   load_balancer_type         = "network"
#   internal                   = true
#   subnets                    = aws_subnet.dmz.*.id
#   enable_deletion_protection = false
#   security_groups            = [aws_security_group.ncc.id]

#   enforce_security_group_inbound_rules_on_private_link_traffic = "off"

#   access_logs {
#     bucket  = aws_s3_bucket.logs.id
#     prefix  = "ncc"
#     enabled = true
#   }

#   depends_on = [aws_s3_bucket_policy.logs]
# }

# resource "aws_lb_target_group" "ncc" {
#   name        = upper("${var.name_prefix}-ncc")
#   port        = 443
#   protocol    = "TCP"
#   target_type = "ip"
#   vpc_id      = aws_vpc.main.id
# }

# resource "aws_lb_target_group_attachment" "ncc" {
#   for_each         = toset(["10.0.16.66", "10.0.14.3", "10.0.35.164"]) # TODO dynamic ipset
#   target_group_arn = aws_lb_target_group.ncc.arn
#   target_id        = each.value
# }

# resource "aws_lb_listener" "ncc" {
#   load_balancer_arn = aws_lb.ncc.arn
#   protocol          = "TCP"
#   port              = 443

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ncc.arn
#   }
# }
