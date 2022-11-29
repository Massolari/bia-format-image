# Package

version       = "0.1.0"
author        = "Douglas M."
description   = "Application to insert Bia's logo on an image"
license       = "MIT"
srcDir        = "src"
bin           = @["bia_format_image_nim"]


# Dependencies

requires "nim >= 1.6.10"

task back, "Compile backend":
  exec("nim c app.nim")

task run_back, "Run backend":
  exec("nim c -r app.nim")

task front, "Compile front":
  exec("nim js -o:index.js --outdir:public front.nim")

task run_front, "Run frontend":
  frontTask()
  exec("fswatch -o ./front.nim | while read f; do nimble front; done")

task all, "Compiles backend and frontend":
  backTask()
  frontTask()
