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

  canvas = document.getElementById('can')
  ctx = canvas.getContext('2d')
  ctx.fillStyle = "white"
  ctx.fillRect 0, 0, 200, 200
  w = canvas.width
  h = canvas.height
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

  draw = ->
    ctx.beginPath()
    ctx.moveTo prevX, prevY
    ctx.lineTo currX, currY
    ctx.strokeStyle = x
    ctx.lineWidth = y
    ctx.stroke()
    ctx.closePath()

  erase = ->
    m = confirm('Want to clear')
    if m
      ctx.clearRect 0, 0, w, h
      document.getElementById('canvasimg').style.display = 'none'

  save = (data_url) ->
    document.getElementById('canvasimg').src = data_url
    document.getElementById('canvasimg').style.display = 'inline'

  get_image_url = ->
    document.getElementById('canvasimg').style.border = '2px solid'
    canvas.toDataURL('image/png', 1)

  findxy = (res, e) ->
    if res == 'down'
      prevX = currX
      prevY = currY
      currX = e.clientX - (canvas.offsetLeft)
      currY = e.clientY - (canvas.offsetTop)
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
        currX = e.clientX - (canvas.offsetLeft)
        currY = e.clientY - (canvas.offsetTop)
        draw()

  recognize = (image) ->
    $.ajax
      url: '/recognize'
      type: 'post'
      data:
        image: image
      success: (data, textStatus, jqXHR) ->
        $('#result').html(jqXHR.responseText)
      error = (jqXHR, textStatus, errorThrown) ->
        alert('Erro ' + errorThrown)

  $(document).on 'click', '#recognize', ->
    image_url = get_image_url()
    save(image_url)
    recognize(image_url)

  $(document).on 'click', '#clear', ->
    erase()