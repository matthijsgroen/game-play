Crafty.defineScene 'GameOver', (data) ->
  # import from globals
  Game = window.Game

  # constructor
  Crafty.background('#000')
  Crafty.viewport.x = 0
  Crafty.viewport.y = 0

  Crafty.e('2D, DOM, Text')
    .attr(x: 0, y: 110, w: 640)
    .text('Game Over')
    .textColor('#FF0000')
    .css('textAlign', 'center')
    .textFont({
      size: '40px'
      weight: 'bold'
      family: 'Press Start 2P'
    })

  Crafty('Player ControlScheme').each (index) ->
    Crafty.e('2D, DOM, Text')
      .attr(x: 0, y: 200 + (index * 30), w: 640)
      .text(@name + ': ' + @points)
      .textColor(@color())
      .css("textAlign", "center")
      .textFont({
        size: '20px'
        weight: 'bold'
        family: 'Press Start 2P'
      })

  # After a timeout, be able to replay
  Crafty.e('Delay').delay ->
    if Game.credits > 0
      time = 10

      text = if Game.credits is 1
        "1 Credit left"
      else
        "#{Game.credits} Credits left"

      Crafty.e('2D, DOM, Text')
        .attr(x: 0, y: 320, w: 640)
        .textColor('#FF0000')
        .css("textAlign", "center")
        .textFont(
          size: '10px'
          weight: 'bold'
          family: 'Press Start 2P'
        )
        .text(text)
      e = Crafty.e('2D, DOM, Text')
        .attr(x: 0, y: 350, w: 640)
        .textColor('#FF0000')
        .css("textAlign", "center")
        .textFont(
          size: '10px'
          weight: 'bold'
          family: 'Press Start 2P'
        )
      prefix = "Press fire to continue"
      e.text("#{prefix} #{"00#{time}".slice(-2)}")
      @delay ->
        time -= 1
        e.text("#{prefix} #{"00#{time}".slice(-2)}")
      , 1000, time, ->
        Crafty.enterScene('Intro')

      Crafty('Player').each ->
        @reset()
        @one 'Activated', ->
          Game.credits -= 1
          Crafty.enterScene Game.firstLevel, data
    else
      @delay ->
        Crafty.enterScene('Intro')
      , 10000

  , 2000, 0
, ->
  # destructor
  Crafty('Delay').each -> @destroy()
  Crafty('Player').each -> @unbind('Activated')