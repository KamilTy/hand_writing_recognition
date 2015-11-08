# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  canvas = undefined
  ctx = undefined
  flag = false
  prevX = 0
  currX = 0
  prevY = 0
  currY = 0
  dot_flag = false
  x = 'black'
  y = 5
  w = 200
  h = 200

  createCanvas = ->
    canvas = document.createElement('canvas')
    canvas.id = "can"
    canvas.className = "canvas-border"
    canvas.width = 200
    canvas.height = 200
    ctx = canvas.getContext('2d')
    ctx.fillStyle = "white"
    ctx.fillRect 0, 0, 200, 200
    canvas.addEventListener 'mousemove', ((e) ->
      findxy 'move', e
      return
    ), false
    canvas.addEventListener 'mousedown', ((e) ->
      findxy 'down', e
      return
    ), false
    canvas.addEventListener 'mouseup', ((e) ->
      findxy 'up', e
      return
    ), false
    canvas.addEventListener 'mouseout', ((e) ->
      findxy 'out', e
      return
    ), false
    document.getElementById('canvas-div').appendChild(canvas)

  resetCanvas = () ->
    ctx = canvas.getContext('2d')
    ctx.fillStyle = "white"
    ctx.fillRect 0, 0, 200, 200

  createCanvas()

  draw = ->
    ctx.beginPath()
    ctx.moveTo prevX, prevY
    ctx.lineTo currX, currY
    ctx.strokeStyle = 'black'
    ctx.lineWidth = y
    ctx.stroke()
    ctx.closePath()

  erase = ->
    swal
      title: 'Limpar'
      text: 'Tem certeza?'
      type: 'warning'
      showCancelButton: true
      closeOnConfirm: false
    , (isConfirm) ->
      if isConfirm
        resetCanvas()
        swal
          title: 'Apagado'
          text: 'Tudo foi apagado'
          type: 'success'

    # m = confirm('Want to clear')
    # if m
    #   resetCanvas()

  save = (data_url) ->
    document.getElementById('canvasimg').src = data_url
    # document.getElementById('canvasimg').style.display = 'inline'

  get_image_url = ->
    document.getElementById('canvasimg').style.border = '2px solid'
    canvas.toDataURL('image/png', 1)

  findxy = (res, e) ->
    if res == 'down'
      prevX = currX
      prevY = currY
      currX = e.clientX - document.getElementById('can').offsetLeft - document.getElementsByClassName('container')[0].offsetLeft
      currY = e.clientY - document.getElementById('main-row').offsetTop - document.getElementById('can').offsetTop + document.documentElement.scrollTop
      flag = true
      dot_flag = true
      if dot_flag
        ctx.beginPath()
        ctx.fillStyle = x
        ctx.fillRect currX, currY, 2, 2
        ctx.closePath()
        dot_flag = false
    if res == 'up' or res == 'out'
      flag = false
    if res == 'move'
      if flag
        prevX = currX
        prevY = currY
        currX = e.clientX - document.getElementById('can').offsetLeft - document.getElementsByClassName('container')[0].offsetLeft
        currY = e.clientY - document.getElementById('main-row').offsetTop - document.getElementById('can').offsetTop + document.documentElement.scrollTop
        draw()

  recognize = (image) ->
    $.ajax
      url: '/recognize'
      type: 'post'
      data:
        image: image
      beforeSend: () ->
        swal
          title: 'Reconhecendo'
          text: 'Aguarde...'
          showConfirmButton: false
      success: (data, textStatus, jqXHR) ->
        $('#result').html(jqXHR.responseText)
      error: (jqXHR, textStatus, errorThrown) ->
        swal
          title: 'Error'
          text: errorThrown
          type: 'danger'
      complete: () ->
        swal.close()
        resetCanvas()

  $(document).on 'click', '#recognize', ->
    image_url = get_image_url()
    save(image_url)
    recognize(image_url)

  $(document).on 'click', '#clear', ->
    erase()
    $('#result').html('')