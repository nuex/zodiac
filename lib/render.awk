# render.awk - Awk-based templating

BEGIN {
  action = "none"
  ext = "none"
  main_content_type = "_main"
  helpers_loaded = "no"
  layout = ""
  filter_cmds["htm"]  = "none"
  filter_cmds["html"] = "none"
  filter_cmds["md"]   = markdown_filter_cmd
}

{
  split(FILENAME, parts, ".")
  ext = parts[length(parts)]
  if (ext == "config") {
    action = "config"
  } else if (ext == "meta") {
    action = "meta"
  } else if (ext == "layout") {
    action = "layout"
  } else {
    # not a known extension, assuming this line
    # is from a page
    content_extension = ext
    action = "page"
  }
}

# Process lines from config
# Also ignore comments and empty lines
action == "config" && (NF > 0) && (!/^;.*/) {
  split($0, filter_kv, ": ")
  split(filter_kv[1], filter_extensions, ",")
  filter_cmd = filter_kv[2]

  for (i = 1; i <= length(filter_extensions); i++) {
    filter_cmds[filter_extensions[i]] = filter_cmd
  }

  next
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
  if (!contents[main_content_type]) {
    contents[main_content_type] = bind_data($0)

    # save the extension for this content type
    # to find the appropriate filter to render it
    content_extensions[main_content_type] = ext
  } else {
    contents[main_content_type] = contents[main_content_type] "\n" bind_data($0)
  }
  next
}

# Process lines from the layout
action == "layout" {

  # replace yield with rendered content
  if (match($0, /{{{yield}}}/)) {
    sub(/{{{yield}}}/, render_content(main_content_type))
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
    print render_content(main_content_type)
  }
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

function render_content(type,     ext_key, content_extension, filter_cmd, txt) {
  ext_key = type "_ext"

  # Get the extension of the content type
  content_extension = content_extensions[type]

  # Get the appropriate filter command for this extension
  filter_cmd = filter_cmds[content_extension]

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
