output "volumes" {
  value = { for key, value in var.volumes : key => {
    id          = databricks_volume.volumes[key].id
    name        = databricks_volume.volumes[key].name
    volume_path = databricks_volume.volumes[key].volume_path
  } }
}
