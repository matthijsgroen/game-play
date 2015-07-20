
# Import
generator = @Game.levelGenerator

generator.defineBlock class extends @Game.LevelBlock
  name: 'Generic.Start'
  delta:
    x: 0
    y: 0
  next: []

  generate: ->

  enter: ->
    super
    x = 0
    text = "Stage #{@level.data.stage}: #{@level.data.title}"
    title = Crafty.e('2D, DOM, Text, Tween, Delay, HUD')
      .attr w: 640, z: 1
      .css 'textAlign', 'center'
      .text text
      .positionHud(
        x: x + @x,
        y: 240,
        z: -1
      )
    title.textColor('#FF0000')
      .textFont({
        size: '30px',
        weight: 'bold',
        family: 'Courier new'
      }).delay( ->
        @tween({ viewportY: title.viewportY + 500, alpha: 0 }, 3000)
        @bind 'TweenEnd', =>
          @destroy()
      , 3000, 0)

generator.defineBlock class extends @Game.LevelBlock
  name: 'Generic.Dialog'
  delta:
    x: 0
    y: 0
  next: []
  inScreen: ->
    super
    @showDialog() if !@settings.triggerOn? or @settings.triggerOn is 'inScreen'

  enter: ->
    super
    @showDialog() if @settings.triggerOn is 'enter'

  leave: ->
    super
    @showDialog() if @settings.triggerOn is 'leave'

  showDialog: (start = 0) ->
    Crafty('Dialog').each -> @destroy()
    dialogIndex = @determineDialog(start)
    if dialogIndex?
      dialog = @settings.dialog[dialogIndex]
      x = 60

      Crafty.e('2D, DOM, Color, Tween, HUD, Dialog')
        .attr(w: 570, h: ((dialog.lines.length + 3) * 20), alpha: 0.5)
        .color('#000000')
        .positionHud(
          x: x - 10
          y: @level.visibleHeight - ((dialog.lines.length + 3) * 20)
          z: 2
        )

      Crafty.e('2D, DOM, Text, Tween, HUD, Dialog')
        .attr( w: 550)
        .text(dialog.name)
        .positionHud(
          x: x
          y: @level.visibleHeight - ((dialog.lines.length + 2) * 20)
          z: 2
        )
        .textColor('#909090')
        .textFont({
          size: '16px',
          weight: 'bold',
          family: 'Courier new'
        })

      for line, i in dialog.lines
        Crafty.e('2D, DOM, Text, Tween, HUD, Dialog')
          .attr( w: 550)
          .text(line)
          .positionHud(
            x: x
            y: @level.visibleHeight - ((dialog.lines.length + 1 - i) * 20)
            z: 2
          )
          .textColor('#909090')
          .textFont({
            size: '16px',
            weight: 'bold',
            family: 'Courier new'
          })

      Crafty.e('Dialog, Delay').delay( =>
          @showDialog(start + 1)
        , 2500 * dialog.lines.length, 0)


  determineDialog: (start = 0) ->
    players = []
    Crafty('Player ControlScheme').each ->
      players.push(@name) if @lives > 0

    for dialog, i in @settings.dialog when i >= start
      canShow = yes

      if dialog.has?
        for playerName in dialog.has
          canShow = no if players.indexOf(playerName) is -1

      if dialog.only?
        for playerName in players
          canShow = no if dialog.only.indexOf(playerName) is -1

      continue unless canShow
      return i
    null

generator.defineBlock class extends @Game.LevelBlock
  name: 'Generic.Event'
  delta:
    x: 0
    y: 0
  next: []

  inScreen: ->
    super
    @settings.inScreen?.apply this

  enter: ->
    super
    @settings.enter?.apply this

  leave: ->
    super
    @settings.leave?.apply this


