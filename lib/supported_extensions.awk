BEGIN {
  extensions="md html"
}

# Process lines from config
# Also ignore comments and empty lines
(NF > 0) && (!/^;.*/) {
  split($0, filter_kv, ": ")
  split(filter_kv[1], filter_extensions, ",")

  for (i = 1; i <= length(filter_extensions); i++) {
    ext = filter_extensions[i]
    if (!match(extensions, ext)) {
      extensions = extensions " " ext
    }
  }
  next
}

END {
  print extensions
}
