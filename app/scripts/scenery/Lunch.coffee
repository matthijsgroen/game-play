generator = @Game.levelGenerator

generator.defineElement 'blockcloud', ->
  v = Math.random()
  blur = (Math.random() * 4.0)
  if v > .2
    y = (Math.random() * 20) + 100
    w = (Math.random() * 20) + 125
    h = (Math.random() * 10) + 50
    c1 = Crafty.e('2D, WebGL, Color').attr(
      z: -300
      w: w
      h: h
      alpha: (Math.random() * 0.8) + 0.2
    ).color '#FFFFFF'
    if Math.random() < 0.7
      c1 = c1.flip('X')
    @addBackground(20 + (Math.random() * 400), y, c1, .5)

  if v < .6
    s = (Math.random() * .20) + .25

    y = 330 - (s * 150)
    w = ((Math.random() * 10) + 70) - (s * 20)
    h = ((Math.random() * 5) + 20) - (s * 10)
    c2 = Crafty.e('2D, WebGL, Color').attr(
      z: -570
      w: w
      h: h
      alpha: (Math.random() * 0.8) + 0.2
    ).color('#FFFFFF')
    if Math.random() < 0.2
      c2 = c2.flip('X')
    @addBackground(30 + Math.random() * 400, y, c2, s)


generator.defineBlock class extends @Game.LevelScenery
  name: 'City.Blackness'
  delta:
    x: 600
    y: 0

  generate: ->
    super

generator.defineBlock class extends @Game.LevelScenery
  name: 'City.OceanOld'
  delta:
    x: 800
    y: 0

  generate: ->
    super

    height = 65
    @add(0, @level.visibleHeight - 10, Crafty.e('2D, Solid').attr(w: @delta.x, h: 10))
    @add(0, @level.visibleHeight - height, Crafty.e('2D, WebGL, Color').attr(w: @delta.x, h: height, z: -300).color('#000080'))
    @addBackground(0, @level.visibleHeight - 155, Crafty.e('2D, WebGL, Color').color('#6060E0').attr({ z: -600, w: (@delta.x * .25) + 1, h: 155 }), .25)

    goldenStripe = Crafty.e('2D, WebGL, Color, GoldenStripe').color('#DDDD00').attr(z: -599, w: (@delta.x * .25), h: 1, alpha: 0)
    @addBackground(0, @level.visibleHeight - 155, goldenStripe, .25)
    @addElement 'blockcloud'
    @addBackground(0, @level.visibleHeight - 125, Crafty.e('2D, WebGL, Color').color('#3030B0').attr({ z: -500, w: (@delta.x * .5) + 1, h: 105 }), .5)
    @addBackground(0, @level.visibleHeight - 90, Crafty.e('2D, WebGL, Color').color('#3030B0').attr({ z: -301, w: (@delta.x * .5) + 1, h: 70 }), .5)

generator.defineBlock class extends @Game.LevelScenery
  name: 'City.OceanToNew'
  delta:
    x: 800
    y: 0
  autoNext: 'Ocean'

  assets: ->
    images: ['water-horizon-old.png', 'water-old.png']
    sprites:
      'water-front-old.png':
        tile: 400
        tileh: 90
        map:
          waterFront1Old: [0, 0]
          waterFront2Old: [1, 0]

  generate: ->
    super
    @addBackground(0, @level.visibleHeight - 155, Crafty.e('2D, WebGL, Image').image('images/water-horizon-old.png').attr(z: -600), .25)
    goldenStripe = Crafty.e('2D, WebGL, Color, GoldenStripe').color('#DDDD00').attr(z: -599, w: (@delta.x * .25), h: 1, alpha: 0)
    @addBackground(0, @level.visibleHeight - 155, goldenStripe, .25)
    @addBackground(0, @level.visibleHeight - 125, Crafty.e('2D, WebGL, Image').image('images/water-old.png').attr(z: -500), .5)

    height = 65
    @add(0, @level.visibleHeight - 10, Crafty.e('2D, Solid').attr(w: @delta.x, h: 10))
    #@add(0, @level.visibleHeight - height, Crafty.e('2D, WebGL, Image').image('images/water-front-old.png').attr(z: -300))

    water1 = Crafty.e('2D, WebGL, waterFront1Old, Wave1').attr(z: -300)
    @add(0, @level.visibleHeight - height, water1)
    water1.originalY = water1.y

    water2 = Crafty.e('2D, WebGL, waterFront2Old, Wave2').attr(z: -300)
    @add(400, @level.visibleHeight - height, water2)
    water2.originalX = water2.x
    water2.originalY = water2.y

generator.defineBlock class extends @Game.LevelScenery
  name: 'City.OpenSpace'
  delta:
    x: 700
    y: 0

  generate: ->
    super
    @add(0, 150, Crafty.e('2D, WebGL, Solid, Color').color('#505045').attr({ w: 42, h: 70 }))
    @add(500, 50, Crafty.e('2D, WebGL, Solid, Color').color('#404045').attr({ w: 82, h: 70 }))
    @add(200, 250, Crafty.e('2D, WebGL, Solid, Color').color('#505045').attr({ w: 52, h: 80 }))
    @add(100, 450, Crafty.e('2D, WebGL, Solid, Color').color('#505045').attr({ w: 52, h: 40 }))
    @add(400, 550, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 82, h: 30 }))

generator.defineBlock class extends @Game.LevelScenery
  name: 'City.TunnelStart'
  delta:
    x: 1000
    y: 0
  autoNext: 'Tunnel'

  generate: ->
    super
    @addBackground(380, @level.visibleHeight - 180, Crafty.e('2D, WebGL, Color').color('#505050').attr({ z: -110, w: 40, h: 180 }), .5)
    @addBackground(380, @level.visibleHeight - 90, Crafty.e('2D, WebGL, Color').color('#606060').attr({ z: -200, w: 40, h: 90 }), .25)
    @addBackground(380, @level.visibleHeight - 360, Crafty.e('2D, WebGL, Color').color('#303030').attr({ z: 22, w: 40, h: 360 }), 1.5)

    @add(0, 0, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 350, h: 15 }))
    @add(350, 0, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 100, h: 70 }))
    @add(450, 0, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 550, h: 25 }))
    @add(380, 0, Crafty.e('2D, WebGL, Color').color('#202020').attr({ z: -10, w: @delta.x - 380, h: @level.visibleHeight }))


generator.defineBlock class extends @Game.LevelScenery
  name: 'City.TunnelEnd'
  delta:
    x: 1000
    y: 0
  autoNext: 'OceanOld'

  generate: ->
    super
    @addBackground(380, @level.visibleHeight - 360, Crafty.e('2D, WebGL, Color').color('#303030').attr({ z: 22, w: 40, h: 360 }), 1.5)
    @addBackground(380, @level.visibleHeight - 180, Crafty.e('2D, WebGL, Color').color('#505050').attr({ z: -110, w: 40, h: 180 }), .5)
    @addBackground(380, @level.visibleHeight - 90, Crafty.e('2D, WebGL, Color').color('#606060').attr({ z: -800, w: 40, h: 90 }), .25)

    h = 15
    @add(0, @level.visibleHeight - h, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 350, h: h }))
    h = 70
    @add(350, @level.visibleHeight - h, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 100, h: h }))
    h = 25
    @add(450, @level.visibleHeight - h, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 550, h: h }))
    @add(0, 0, Crafty.e('2D, WebGL, Color').color('#202020').attr({ z: -10, w: 380, h: @level.visibleHeight }))

generator.defineBlock class extends @Game.LevelScenery
  name: 'City.Tunnel'
  delta:
    x: 1000
    y: 0

  generate: ->
    super
    @add(0, 0, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 350, h: 15 }))
    @add(350, 0, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 100, h: 70 }))
    @add(450, 0, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 550, h: 25 }))

    h = 15
    @add(0, @level.visibleHeight - h, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 350, h: h }))

    h = 70
    @add(350, @level.visibleHeight - h, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 100, h: h }))

    h = 25
    @add(450, @level.visibleHeight - h, Crafty.e('2D, WebGL, Solid, Color').color('#404040').attr({ w: 550, h: h }))

    @add(0, 0, Crafty.e('2D, WebGL, Color').color('#202020').attr({ z: -1, w: @delta.x, h: @level.visibleHeight }))

