BEGIN {
  section = "none"
  action = "config"
}

END {
  for (ext in filter) {
    exts[ext_count++] = "-name \"*." ext "\""
  }
  for (i = 0; i < length(ignore); i++) {
    opts[opt_count++] = "!"
    opts[opt_count++] = "-name \"" ignore[i] "\""
  }
  if (phase == "render") {
    opts[opt_count++] = exts[0]
    for (i = 1; i < length(exts); i++) {
      opts[opt_count++] = "-o"
      opts[opt_count++] = exts[i]
    }
  } else if (phase == "copy") {
    for (i = 0; i < length(exts); i++) {
      opts[opt_count++] = "!"
      opts[opt_count++] = exts[i]
    }
  }
  for (i = 0; i < length(opts); i++) {
    optpart = optpart " " opts[i]
  }
  printf "find \"%s\" -type f \\( %s \\) -exec zod-%s \"%s\" \"%s\" \"%s\" {} \\;", proj, optpart, phase, zod_lib, proj, target
}
