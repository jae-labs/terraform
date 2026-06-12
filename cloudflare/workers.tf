resource "cloudflare_workers_script" "scripts" {
  for_each = local.worker_scripts

  account_id     = local.account_id
  script_name    = each.key
  content_file   = "${path.module}/${each.value.content_file}"
  content_sha256 = filesha256("${path.module}/${each.value.content_file}")
  main_module    = each.value.content_file

  compatibility_date = each.value.compatibility_date
}

resource "cloudflare_workers_custom_domain" "custom_domains" {
  for_each = local.worker_custom_domains

  account_id = local.account_id
  zone_id    = cloudflare_zone.zones[each.value.zone].id
  hostname   = each.value.hostname
  service    = cloudflare_workers_script.scripts[each.value.service].script_name
}
