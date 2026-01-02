output "service_endpoint" {
  value       = module.simple_webapp.service_endpoint
  description = "The endpoint for the Kubernetes service"
}
