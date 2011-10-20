#
# Parse zodiac config
#

# Ignore comments and empty lines
action == "config" && (NF == 0 || /^;/) {
  next
}

# Get the current section
action == "config" && (/^\[/ && match($0, /\[([[:alnum:]_]).*\]/)) {
  section = substr($0, (RSTART + 1), (RLENGTH - 2))
  next
}

# Get filters in the parse section
action == "config" && section == "parse" {
  n = split($0, exts, ",")
  for (i in exts) {
    ext = exts[i]
    gsub(/ /, "", ext)
    filter[ext] = "none"
  }
  next
}

# Get filters in the parse_convert section
action == "config" && section == "parse_convert" && (NF > 1) {
  ext_list = $1
  cmd = $2
  n = split(ext_list, exts, ",")
  for (i in exts) {
    ext = exts[i]
    gsub(/ /, "", ext)
    filter[ext] = cmd
  }
  next
}

# Get ignore patterns
action == "config" && section == "ignore" {
  ignore[ignore_count++] = $0
  next
}
