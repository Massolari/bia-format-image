# app.nim
import os
import std/json
import std/strformat
import std/strutils
import prologue
import prologue/middlewares/staticfile

const
  imagesPath = "public/img"
  imageName = "image"
  resultName = "result.png"

proc home*(ctx: Context) {.async.} =
  await ctx.staticFileResponse("index.html", "public")

proc applyLogo*(ctx: Context) {.async.} =
  let file = ctx.getUploadFile("file")
  let extension = file.filename.split('.')[^1]
  echo(fmt"File extension: {extension}")
  file.save(imagesPath, fmt"{imageName}.{extension}")

  let result = execShellCmd("sh ./apply_watermark.sh")

  var
    status = 200
    body = fmt"/{imagesPath}/{resultName}"

  if result == 1:
      status = 500
      body = "An error occurred"

  resp jsonResponse(%*{"status": status, "body": body})

var app = newApp()
app.addRoute("/", home, HttpGet)
app.addRoute("/logo", applyLogo, HttpPost)
app.use(staticFileMiddleware("public"))
app.run()
