# render.awk - Awk-based templating

BEGIN {
  action = "none"
  helpers_loaded = "no"
  content = ""
  layout = ""
}

{
  action = action_from_filetype(FILENAME)
}

# Process lines from meta files
action == "meta" {
  split($0, kv, ": ")
  data[kv[1]] = kv[2]
  next
}

# Done processing meta
# Since data is loaded now, load the helpers
action != "meta" && helpers_loaded == "no" && helpers == "yes" {
  load_helpers()
  helpers_loaded = "yes"
}

# Process lines from the page
action == "page" {
  if (content == "") {
    content = bind_data($0)
  } else {
    content = content "\n" bind_data($0)
  }
  next
}

# Process lines from the layout
action == "layout" {

  # replace yield with rendered content
  if (match($0, /{{{yield}}}/)) {
    sub(/{{{yield}}}/, render_content(content))
  }

  if (layout == "") {
    layout = bind_data($0)
  } else {
    layout = layout "\n" bind_data($0)
  }
}

END {
  if (layout != "") {
    print layout
  } else {
    print render_content(content)
  }
}

function action_from_filetype(filename) {
  if (match(filename, /\.meta/)) return "meta"
  if (match(filename, /\.layout/)) return "layout"
  if (match(filename, /\.md/)) return "page"
}

function bind_data(txt,   tag, key) {
  if (match(txt, /{{([^}]*)}}/)) {
    tag = substr(txt, RSTART, RLENGTH)
    match(tag, /(\w|[?]).*[^}]/)
    key = substr(tag, RSTART, RLENGTH)
    gsub(tag, data[key], txt)
    return bind_data(txt, data)
  } else {
    return txt
  }
}

function render_content(txt) {
  return markdown(txt)
}

function markdown(txt,    rand_date, tmpfile, rendered_txt, date_cmd, markdown_cmd, line) {
  date_cmd = "date +%Y%m%d%H%M%S"
  date_cmd | getline rand_date
  close(date_cmd)

  tmpfile = "/tmp/render" rand_date
  markdown_cmd = "awk -f " AWKLIB "/markdown.awk > " tmpfile

  # pipe content to markdown.awk
  print txt | markdown_cmd
  close(markdown_cmd)

  # pull out the filtered page
  while((getline line < tmpfile) > 0) {
    rendered_txt = rendered_txt "\n" line
  }
  close(tmpfile)
    
  system("rm " tmpfile)

  return rendered_txt
}
