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
  let
    file = ctx.getUploadFile("upload_file")
    extension = file.filename.split('.')[^1]
    logoPosition = ctx.getQueryParams("position", "NorthEast")
  echo(fmt"File extension: {extension}")
  file.save(imagesPath, fmt"{imageName}.{extension}")

  let
    result = execShellCmd("sh ./apply_watermark.sh " & logoPosition)
    (status, body) = (
      if result == 1:
        (500, "An error has occurred")
      else:
        (200, fmt"/{imagesPath}/{resultName}")
    )

  resp jsonResponse(%*{"status": status, "body": body})

var app = newApp()
app.addRoute("/", home, HttpGet)
app.addRoute("/logo", applyLogo, HttpPost)
app.use(staticFileMiddleware("public"))
app.run()
