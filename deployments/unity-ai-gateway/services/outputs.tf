output "services" {
  value = { for key, value in databricks_ai_gateway_model_service.whitelist_models : key => {
    name                = databricks_ai_gateway_model_service.whitelist_models[key].name
    supported_api_types = databricks_ai_gateway_model_service.whitelist_models[key].supported_api_types
  } }
}
