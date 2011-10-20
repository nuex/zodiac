#
# Build find options
#

BEGIN {
  section = "none"
  action = "config"
}

END {
  for (ext in filter) {
    exts[ext_count++] = "\"" "*." ext "\""
  }
  for (i = 0; i < length(ignore); i++) {
    instructions[inst_count++] = "not"
    instructions[inst_count++] = "\"" ignore[i] "\""
  }
  if (phase == "render") {
    instructions[inst_count++] = exts[0]
    for (i = 1; i < length(exts); i++) {
      instructions[inst_count++] = "or"
      instructions[inst_count++] = exts[i]
    }
  } else if (phase == "copy") {
    for (i = 0; i < length(exts); i++) {
      instructions[inst_count++] = "not"
      instructions[inst_count++] = exts[i]
    }
  }
  # print all instructions
  for (i = 0; i < length(instructions); i++) {
    instruction = instruction " " instructions[i]
  }
  print instruction
}
