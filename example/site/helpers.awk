{ helpers = "yes" }

function load_helpers() {
  data["page_title"] = page_title()
}

function page_title(  title) {
  if (data["title"]) {
    title = data["title"] " - " data["site_title"]
  } else {
    title = data["site_title"]
  }
  return title
}
