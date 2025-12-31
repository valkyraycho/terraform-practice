output "user_arn" {
  value       = aws_iam_user.example.arn
  description = "The ARN assigned by AWS for the user"
}
