package = "prirustak"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/michal-h21/prirustak.git"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      ["lustache.lustache"] = "lib/lustache/lustache.lua",
      ["lustache.lustache.context"] = "lib/lustache/lustache/context.lua",
      ["lustache.lustache.renderer"] = "lib/lustache/lustache/renderer.lua",
      ["lustache.lustache.scanner"] = "lib/lustache/lustache/scanner.lua",
      ["pl.lapp"] = "lib/pl/lapp.lua",
      ["pl.sip"] = "lib/pl/sip.lua",
      print_r = "lib/print_r.lua",
      ["parse_prir"] = "parse_prir.lua",
      ["prirtocsv"] = "prirtocsv.lua"
   }
}
