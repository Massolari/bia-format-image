{.experimental: "caseStmtMacros".}

include karax/[prelude, kajax]
import fusion/matching
import std/options
import sugar

const spinner = """
<svg viewBox="0 0 24 24" fill="none" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"><circle stroke-width="4" stroke="currentColor" r="10" cy="12" cx="12" class="opacity-25"></circle><path d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" fill="currentColor" class="opacity-75"></path></svg>
"""

type
  RemoteDataEnum = enum
    rdNotAsked,
    rdLoading,
    rdFailure,
    rdSuccess
  DownloadLink = object
    case kind: RemoteDataEnum
    of rdNotAsked: discard
    of rdLoading: progress: Option[int]
    of rdFailure: error: string
    of rdSuccess: link: cstring
  ResponseData = ref object
    body: cstring
    status: int

var
  logoPosition = "NorthEast"
  downloadLink: DownloadLink = DownloadLink(kind: rdNotAsked)
  buttonLoading =
    buildHtml(span(class = "btn-spinner")):
      verbatim(spinner)

proc getChecked(checkValue: string, currentValue: string): cstring =
  if checkValue == currentValue:
    cstring("checked")
  else:
    cstring(nil)

proc logoPositionCheckbox(value: string, label: string): VNode =
  buildHtml(label):
    input(type = "radio", name = "position", id = value, value = value,
      checked = getChecked(value, logoPosition), onchange = () => (logoPosition = value))
    text label

proc handleOnClick() =
  document.querySelector("input[type=file]").click()

proc onProgress(data: ProgressEvent) =
  downloadLink = DownloadLink(kind: rdLoading, progress: some(int(data.loaded /
      data.total) * 100))
  redraw()

proc onFileResponse(httpStatus: int, response: cstring) =
  if httpStatus != 200:
    downloadLink = DownloadLink(kind: rdFailure, error: "Ocorreu um erro");
  else:
    let data = response.fromJson[:ResponseData]
    downloadLink = DownloadLink(kind: rdSuccess, link: data.body)
  redraw()

proc handleOnChangeFile(ev: dom.Event, n: VNode) =
  let file = InputElement(ev.target).files[0]

  downloadLink = DownloadLink(kind: rdLoading, progress: none(int))
  uploadFile(url = cstring("/logo?position=" & logoPosition), file = file,
      cont = onFileResponse, onprogress = onProgress)

proc sendingText(loaded: int): string =
  if loaded == 100:
    "Processando imagem"
  else:
    "Enviando: " & $loaded & "%"

proc createDom(): VNode =
  let (buttonContent, buttonDisabled) =
    if downloadLink.kind == rdLoading:
      (buttonLoading, "disabled".cstring)
    else:
      (text "Selecionar foto", cstring(nil))
  result = buildHtml(tdiv):
    header:
      img(class = "logo", src = "public/img/logo.png")
    span(class = "main"):
      p:
        text "Selecione a foto que deseja inserir a marca d'agua"
      tdiv:
        fieldset:
          legend:
            text "Posição da logo"
          tdiv:
            logoPositionCheckbox("NorthWest", "Superior esquerdo")
            logoPositionCheckbox("NorthEast", "Superior direito")
        input(type = "file", onchange = handleOnChangeFile)
        button(
          class = "select-file",
          disabled = buttonDisabled,
          onclick = handleOnClick
        ):
          buttonContent
        p:
          case downloadLink:
          of NotAsked(): text ""
          of Loading(progress: @progress):
            case progress
            of Some(@actualProgress):
              text sendingText(actualProgress)
            of None():
              text ""
          of Success(link: @actualLink):
            a(href = actualLink, download = ""):
              text "Baixar imagem"
          of Failure(error: @errorMsg):
            text errorMsg

setRenderer createDom
