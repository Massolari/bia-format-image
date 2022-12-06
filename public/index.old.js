const button = document.querySelector('button')
const input = document.querySelector('input')
const download = document.querySelector('p')

function setLoading(value) {
    let buttonContent = 'Selecionar foto'
    if (value) {
        buttonContent = `<span class="btn-spinner">${spinner} Enviando</span>`

    }
    button.innerHTML = buttonContent
    button.disabled = value
}

function renderDownload(link) {
    const content = (link.length > 0) ? `<a href="${link}" download>Baixar imagem</a>` : ''

    download.innerHTML = content
}

const spinner = `<svg viewBox="0 0 24 24" fill="none" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white"><circle stroke-width="4" stroke="currentColor" r="10" cy="12" cx="12" class="opacity-25"></circle><path d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" fill="currentColor" class="opacity-75"></path></svg>`

button.addEventListener('click', () => input.click())

input.addEventListener('change', event => {
    const file = event.target.files[0]

    renderDownload('')

    const form = new FormData()
    form.append('file', file)

    fetch('/logo', {
        method: 'POST',
        body: form
    })
        .then(res => res.json())
        .then(response => {
            const link = (response.status == 200) ? response.body : ""
            renderDownload(link)
        })
        .finally(() => setLoading(false))

    setLoading(true)

})

setLoading(false)

