output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs.id
}