locals {
  content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"

    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    png  = "image/png"
    gif  = "image/gif"
    svg  = "image/svg+xml"
    webp = "image/webp"
  }
}

locals {
  processed_objects = {
    for obj in var.objects : obj.key => merge(obj, {
      content_type = coalesce(
        obj.content_type,
        lookup(
          local.content_types,
          lower(element(split(".", obj.source), length(split(".", obj.source)) - 1)),
          "binary/octet-stream"
        )
      )
    })
  }
}