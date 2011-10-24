#
# Render a zodiac page
#

BEGIN {
  action = "none"
  ext = "none"
  main = "_main"
  helpers_loaded = "no"
  layout = ""
}

{
  split(FILENAME, parts, ".")
  ext = parts[length(parts)]
  if (FILENAME == "-") {
    action = "config"
  } else if (ext == "meta") {
    action = "meta"
  } else if (ext == "layout") {
    action = "layout"
  } else {
    action = "page"
    filter_ext = ext
  }
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
  if (!contents[main]) {
    contents[main] = bind_data($0)

    # save the extension for this content type
    # to find the appropriate filter to render it
    filter_exts[main] = ext
  } else {
    contents[main] = contents[main] "\n" bind_data($0)
  }
  next
}

# Process lines from the layout
action == "layout" {

  # replace yield with rendered content
  if (match($0, /{{{yield}}}/)) {
    sub(/{{{yield}}}/, render_content(main))
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
    print render_content(main)
  }
}

function bind_data(txt,   tag, key) {
  if (match(txt, /{{([^}]*)}}/)) {
    tag = substr(txt, RSTART, RLENGTH)
    match(tag, /([[:alnum:]_]|[?]).*[^}]/)
    key = substr(tag, RSTART, RLENGTH)
    gsub(tag, data[key], txt)
    return bind_data(txt, data)
  } else {
    return txt
  }
}

function render_content(type,     ext_key, filter_ext, filter_cmd, txt) {
  ext_key = type "_ext"

  # Get the extension of the content type
  filter_ext = filter_exts[type]

  # Get the appropriate filter command for this extension
  filter_cmd = filter[filter_ext]

  # Get the text of the content for the given type
  txt = contents[type]

  if (filter_cmd != "none") {
    return run_filter(filter_cmd, txt)
  } else {
    return txt
  }
}

function run_filter(cmd, txt,   rand_date, tmpfile, rendered_txt, date_cmd, markdown_cmd, line) {
  date_cmd = "date +%Y%m%d%H%M%S"
  date_cmd | getline rand_date
  close(date_cmd)

  tmpfile = "/tmp/awk_render" rand_date
  filter_cmd = cmd " > " tmpfile

  # pipe content to filter.awk
  print txt | filter_cmd
  close(filter_cmd)

  # pull out the filtered page
  while((getline line < tmpfile) > 0) {
    rendered_txt = rendered_txt "\n" line
  }
  close(tmpfile)
    
  system("rm " tmpfile)

  return rendered_txt
}
