# Package

version       = "0.1.0"
author        = "Douglas M."
description   = "Application to insert Bia's logo on an image"
license       = "MIT"
srcDir        = "src"
bin           = @["app"]


# Dependencies

requires "nim >= 1.6.10"
requires "prologue"
requires "karax"
requires "fusion"

task back, "Compile backend":
  exec("nim c src/app.nim")

task run_back, "Run backend":
  exec("nim c -r src/app.nim")

task front, "Compile front":
  exec("nim js -o:index.js --outdir:public src/front.nim")

task run_front, "Run frontend":
  frontTask()
  exec("fswatch -o src/front.nim | while read f; do nimble front; done")

task all, "Compiles backend and frontend":
  backTask()
  frontTask()
