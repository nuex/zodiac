{ helpers = "yes" }

function load_helpers() {
  data["page_title"] = page_title()
}

function page_title(  title) {
  if ("title" in data) {
    return data["title"] " - " data["site_title"]
  } else {
    return data["site_title"]
  }
}
