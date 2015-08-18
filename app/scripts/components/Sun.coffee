Crafty.c 'Sun',
  init: ->
    @requires '2D, Canvas, Color, ViewportRelativeMotion, Tween, Collision'
    @attr(w: 60, h: 60, z: -1000)
      .color('#DDDD00')

    @glare = []
    directGlare = Crafty.e('2D, Canvas, Color, Glare')
      .attr
        x: -15
        y: -15
        w: 90
        h: 90
        z: 90
        alpha: 0.4
        originalAlpha: 0.4
      .color('#FFFFFF')
    @attach directGlare
    @glare.push directGlare

    blueGlare = Crafty.e('2D, Canvas, Color, Glare')
      .attr
        mirrored: yes
        w: 80
        h: 80
        z: 91
        res: 0.9
        alpha: 0.7
        originalAlpha: 0.7
      .color('#B0B0FF')
    @attach blueGlare
    @glare.push blueGlare

    redGlare = Crafty.e('2D, Canvas, Color, Glare')
      .attr
        mirrored: yes
        w: 10
        h: 10
        z: 92
        res: 0.82
        alpha: 0.8
        originalAlpha: 0.8
      .color('#FF9090')
    @attach redGlare
    @glare.push redGlare

    bigGlare = Crafty.e('2D, Canvas, Color, Glare')
      .attr
        mirrored: yes
        w: 200
        h: 200
        z: 93
        alpha: 0.2
        res: 1.1
        originalAlpha: 0.2
      .color('#FF9090')
    @attach bigGlare
    @glare.push bigGlare

  sun: (position) ->
    { x, y } = position
    vx = Crafty.viewport.width / 2
    dx = x - vx
    @viewportRelativeMotion(
      x: x
      y: y
      speed: 0
    )
    .attr(dx: dx)

    @bind 'EnterFrame', @_updateGlare
    this

  remove: ->
    @unbind 'EnterFrame'

  _updateGlare: ->
    covered = [0]
    sunArea = @area()

    for o in @hit('2D')
      continue if o.obj is this
      continue if o.obj.has 'Glare'
      continue if o.obj.has 'HUD'
      e = o.obj
      xMin = Math.max(@x, e.x)
      xMax = Math.min(@x + @w, e.x + e.w)
      w = xMax - xMin
      yMin = Math.max(@y, e.y)
      yMax = Math.min(@y + @h, e.y + e.h)
      h = yMax - yMin
      covered.push(w * h)

    maxCoverage = Math.max(covered...) * 1.7
    perc = maxCoverage / sunArea
    perc = 1 if maxCoverage > sunArea

    hw = Crafty.viewport.width / 2
    hh = Crafty.viewport.height / 2
    dx = @x + (@w / 2) - ((Crafty.viewport._x * -1) + hw)
    dy = @y + (@h / 2) - ((Crafty.viewport._y * -1) + hh)
    px = dx / hw
    py = dy / hh

    for e in @glare
      e.attr alpha: e.originalAlpha * (1 - perc)
      if e.mirrored
        #console.log py, px
        e.attr
          x: @x + (@w / 2) - (e.w / 2) - (dx * 2 * e.res)
          y: @y + (@h / 2) - (e.h / 2) - (dy * 2 * e.res)

