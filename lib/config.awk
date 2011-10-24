#
# Parse zodiac config
#

action == "config" && (NF == 0 || /^;/) {
  next
}

action  == "config" && match($0, /\[([[:alnum:]_]).*\]/) {
  section = substr($0, (RSTART + 1), (RLENGTH - 2))
  next
}

action == "config" && section == "parse" {
  n = split($0, exts, ",")
  for (i in exts) {
    ext = exts[i]
    gsub(/ /, "", ext)
    filter[ext] = "none"
  }
  next
}

action == "config" && section == "parse_convert" && (NF > 1) {
  ext_list = $1
  cmd = substr($0, length(ext_list) + 1)
  n = split(ext_list, exts, ",")
  for (i in exts) {
    ext = exts[i]
    gsub(/ /, "", ext)
    filter[ext] = cmd
    print cmd >> "awk.log"
  }
  next
}

action == "config" && section == "ignore" {
  ignore[ignore_count++] = $0
}
