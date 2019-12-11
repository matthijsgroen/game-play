LevelScenery = require('src/lib/LevelScenery').default
cityScenery = require('src/images/city-scenery.png')
citySceneryMap = require('src/images/city-scenery.map.json')
extend = require('lodash/extend')
introShipComposition = require('src/data/compositions/IntroShip.composition.json')
levelGenerator = require('src/lib/LevelGenerator')
{ lookup } = require('src/lib/random')

levelGenerator.defineElement 'cloud', ->
  v = lookup()
  blur = (lookup() * 4.0)
  if v > .2
    y = (lookup() * 20) + 30
    w = (lookup() * 20) + 125
    h = (lookup() * 10) + 50
    c1 = Crafty.e('2D, WebGL, cloud, Hideable, Horizon').attr(
      z: -300
      w: w
      h: h
      topDesaturation: 0.6
      bottomDesaturation: 0.6
      alpha: (lookup() * 0.8) + 0.2
      lightness: .4
      #blur: blur
    )
    if lookup() < 0.7
      c1 = c1.flip('X')
    @addBackground(300 + (lookup() * 300), y, c1, .375)

  if v < .6
    s = (lookup() * .20) + .15

    y = 230 - (s * 150)
    w = ((lookup() * 10) + 70) - (s * 20)
    h = ((lookup() * 5) + 20) - (s * 10)
    c2 = Crafty.e('2D, WebGL, cloud, Hideable, Horizon').attr(
      z: -570
      w: w
      h: h
      topDesaturation: 1.0 - s
      bottomDesaturation: 1.0 - s
      alpha: (lookup() * 0.8) + 0.2
      lightness: .4
      #blur: blur
    )
    if lookup() < 0.2
      c2 = c2.flip('X')
    @addBackground(360 + lookup() * 300, y, c2, s)

levelGenerator.defineElement 'waterHorizon', ->
  h = Crafty.e('2D, WebGL, waterHorizon, SunBlock, Horizon, ColorEffects')
    .attr(z: -600, w: 257)
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(1.0, .2)
  if Game.webGLMode is off
    h.attr lightness: .6
  @addBackground(0, @level.visibleHeight - 225, h, .25)

  goldenStripe = Crafty.e('2D, WebGL, Gradient, GoldenStripe')
    .topColor('#DDDD00')
    .bottomColor('#DDDD00', if Game.webGLMode isnt off then 0 else 1)
    .attr(z: -599, w: (@delta.x * .25), h: 1, alpha: 0)
  @addBackground(0, @level.visibleHeight - 225, goldenStripe, .25)

levelGenerator.defineElement 'water', ->
  h = Crafty.e('2D, WebGL, waterMiddle, Horizon')
    .crop(1, 0, 511, 192)
    .attr(z: -500, w: 513)
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.7, -.4)
  if Game.webGLMode is off
    h.attr lightness: .8
  @addBackground(0, @level.visibleHeight - 150, h, .5)

  @level.registerWaveTween 'OceanWavesMiddle', 5500, 'easeInOutQuad', (v, forward) ->
    moveh = 5
    distanceh = 20
    height = 192
    Crafty('waterMiddle').each ->
      if forward
        @dy = (v * moveh)
        @h = height - (v * distanceh)
      else
        @dy = moveh - (v * moveh)
        @h = height - distanceh + (v * distanceh)

levelGenerator.defineElement 'waterFront', ->
  height = 65
  @add(0, @level.visibleHeight - 45, Crafty.e('2D, ShipSolid, BulletSolid, GravityLiquid').attr(w: @delta.x, h: 45))

  water1 = Crafty.e('2D, Delta2D, WebGL, waterFront1, Wave1')
    .attr(z: -20)
    .crop(0, 1, 512, 95)
  @add(0, @level.visibleHeight - height, water1)
  #water1.waveY = 0

  water2 = Crafty.e('2D, Delta2D, WebGL, waterFront2, Wave2')
  water1.attach(water2)
  water2.attr(
      z: -20
      x: water1.x + water1.w
      y: water1.y
    )
    .crop(0, 1, 512, 95)

  @level.registerWaveTween 'OceanWaves', 6000, 'easeInOutQuad', (v, forward) ->
    distance = 50
    distanceh = 40
    moveh = 8
    width = 513
    height = 125

    Crafty('Wave1').each ->
      w = width + (v * distance)
      y = (v * moveh)
      h = height - (v * distanceh)

      if !forward
        w = width + distance - (v * distance)
        y = moveh - (v * moveh)
        h = height - distanceh + (v * distanceh)
      wShift = w - @w
      @attr(dy: y, w: w, h: h)

    Crafty('Wave2').each ->
      if forward
        w = width - (v * distance)
        h = height - (v * distanceh)
      else
        w = width - distance + (v * distance)
        h = height - distanceh + (v * distanceh)
      wShift = width - w
      @attr(dx: wShift, w: w, h: h)

    Crafty('WaveFront').each ->
      width = 1200
      distance = 120
      height = 200
      distanceh = 80

      if forward
        w = width + (v * distance)
        y = (v * moveh)
        h = height - (v * distanceh)
      else
        w = width + distance - (v * distance)
        y = moveh - (v * moveh)
        h = height - distanceh + (v * distanceh)

      @shift(0, y - @waveY, w - @w, h - @h)
      @waveY = y

levelGenerator.defineElement 'cityHorizon', (mode) ->
  @addElement 'waterHorizon'
  e = if mode is 'start'
    Crafty.e('2D, WebGL, coastStart, SunBlock, Horizon')
  else
    Crafty.e('2D, WebGL, coast, SunBlock, Horizon')
  e.colorDesaturation(Game.backgroundColor)
    .saturationGradient(.9, .8)
    .crop(1, 0, 255, 32)
    .attr(z: -598, w: 256)
  @addBackground(0, @level.visibleHeight - 225 - 16, e, .25)

levelGenerator.defineElement 'cityDistance', (mode) ->
  e = Crafty.e('2D, WebGL, cityDistance, SunBlock, Horizon')
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.9, .6)
    .crop(1, 1, 255, 223)
    .attr(z: -598, w: 256)

  @addBackground(0, @level.visibleHeight - 225 - 16, e, .25)

levelGenerator.defineElement 'cityNoCollision', ->
  bg = Crafty.e('2D, WebGL, cityLayer2, Horizon, Flipable')
    .attr(z: -505) #, blur: 1.2)
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.6, .6)
  @addBackground(0, @level.visibleHeight - 350, bg, .375)

  e = Crafty.e('2D, WebGL, city, Horizon')
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.4, .4)
    .crop(0, 0, 511, 288)
    .attr(z: -305, w: 513)

  @addBackground(0, @level.visibleHeight - 310, e, .5)

levelGenerator.defineElement 'city', ->
  bg = Crafty.e('2D, WebGL, cityLayer2, Collision, SunBlock, Horizon, Flipable')
    .attr(z: -505) #, blur: 1.2)
    .collision([4, 29, 72, 29, 72, 118, 4, 118])
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.6, .6)
  @addBackground(0, @level.visibleHeight - 350, bg, .375)

  e = Crafty.e('2D, WebGL, city, Collision, SunBlock, Horizon')
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.4, .4)
    .crop(0, 0, 511, 288)
    .attr(z: -305, w: 513)
  e.collision([35, 155, 35, 10, 130, 10, 160, 155])

  c = Crafty.e('2D, Collision, SunBlock')
  c.attr(w: e.w, h: e.h)
  c.collision([190, 155, 170, 80, 210, 10, 280, 10, 280, 155])

  d = Crafty.e('2D, Collision, SunBlock')
  d.attr(w: e.w, h: e.h)
  d.collision([370, 155, 370, 40, 505, 40, 505, 155])

  @addBackground(0, @level.visibleHeight - 310, e, .5)
  @addBackground(0, @level.visibleHeight - 310, c, .5)
  @addBackground(0, @level.visibleHeight - 310, d, .5)

levelGenerator.defineElement 'cityFrontTop', ->
  bb = Crafty.e('2D, WebGL, bigBuildingTop, RiggedExplosion').attr(z: -20).crop(1, 1, 446, 6 * 32)
  @add(0, @level.visibleHeight - 1200, bb)
  cs = Crafty.e('2D, SunBlock')
    .attr(
      x: bb.x + 10
      y: bb.y + 20
      z: -10
      h: 650
      w: bb.w - 45
    )
  bb.attach(cs)

  for i in [0...3]
    floor = Crafty.e('2D, WebGL, bigBuildingLayer').attr(z: -20).crop(1, 0, 446, 4 * 32)
    floor.attr(x: bb.x, y: bb.y + bb.h + (i * floor.h))
    bb.attach(floor)

  bb.bind('BigExplosion', ->
    return if @buildingExploded
    if @x + @w > -Crafty.viewport.x and @x < -Crafty.viewport.x + Crafty.viewport.width

      Crafty.e('2D, WebGL, glass, Tween')
        .attr(x: @x, y: @y + 40, z: @z + 5)
        .bind('TweenEnd', -> @destroy())
        .tween({ y: @y + 500}, 3000, 'easeInQuad')

      Crafty.e('2D, WebGL, glass, Tween')
        .attr(x: @x + 200, y: @y + 60, z: @z + 5)
        .bind('TweenEnd', -> @destroy())
        .tween({ y: @y + 500}, 3000, 'easeInQuad')

      Crafty.e('2D, WebGL, glass, Tween')
        .attr(x: @x, y: @y + 180, z: @z + 5)
        .bind('TweenEnd', -> @destroy())
        .tween({ y: @y + 500}, 3000, 'easeInQuad')

      Crafty.e('2D, WebGL, glass, Tween')
        .attr(x: @x + 180, y: @y + 200, z: @z + 5)
        .bind('TweenEnd', -> @destroy())
        .tween({ y: @y + 500}, 3000, 'easeInQuad')

      @sprite(30, 13)
      for e in @_children
        e.sprite(30, 19) if e.has('bigBuildingLayer')
      @buildingExploded = yes
  )

levelGenerator.defineElement 'cityFront', (height = 6, offSet = 0, bottomVariant = 'bigBuildingBottom') ->
  bb = Crafty.e('2D, WebGL, bigBuildingTop, Collision, SunBlock, ColorEffects').attr(z: -20).crop(1, 1, 446, 6 * 32)
  bb.colorOverride('#001fff', 'partial')
  calcHeight = (height + 2.5) * 128
  bb.collision([32, 80, 160, 16, 416, 16, 416, calcHeight, 32, calcHeight])
  @add(offSet, @level.visibleHeight - calcHeight - 16, bb)

  for i in [0...height]
    floor = Crafty.e('2D, WebGL, bigBuildingLayer, ColorEffects').attr(z: -20).crop(1, 0, 446, 4 * 32)
    floor.attr(x: bb.x, y: bb.y + bb.h + (i * floor.h))
    bb.attach(floor)

  bottom = Crafty.e("2D, WebGL, #{bottomVariant}, ColorEffects").attr(z: -20).crop(1, 1, 446, 184)
  bottom.attr(x: bb.x, y: bb.y + bb.h + (height * 128))
  bb.attach(bottom)

levelGenerator.defineElement 'cityFrontBlur', ->
  @addBackground(200, @level.visibleHeight - 1350, Crafty.e('2D, WebGL, bigBuildingTop').crop(1, 1, 446, 6 * 32).attr(w: 768, h: 288, z: 50, lightness: .4), 1.5)

levelGenerator.defineElement 'city-bridge', ->
  bg = Crafty.e('2D, WebGL, cityLayer2, Collision, SunBlock, Horizon')
    .collision([4, 29, 72, 29, 72, 118, 4, 118])
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.6, .6)
    .attr(z: -505) #, blur: 1.2)
  @addBackground(0, @level.visibleHeight - 350, bg, .375)

  e = Crafty.e('2D, WebGL, cityBridge, Collision, Horizon')
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.4, .4)
    .crop(0, 0, 511, 160)
    .attr(z: -305, w: 513)
  e.collision([35, 155, 35, 0, 130, 0, 130, 155])

  @addBackground(0, @level.visibleHeight - 182, e, .5)

levelGenerator.defineElement 'cityStart', ->
  e = Crafty.e('2D, WebGL, cityStart, Collision, SunBlock, Horizon')
    .attr(z: -305)
    .colorDesaturation(Game.backgroundColor)
    .saturationGradient(.4, .4)
  e.collision([215, 155, 215, 60, 300, 60, 300, 10, 500, 10, 500, 155])
  @addBackground(0, @level.visibleHeight - 310, e, .5)

class CityScenery extends LevelScenery
  assets: ->
    sprites:
      "#{cityScenery}": citySceneryMap

levelGenerator.defineBlock class extends CityScenery
  name: 'City.Intro'
  delta:
    x: 1024
    y: 0
  autoNext: 'City.Ocean'

  generate: ->
    super

    @addElement 'waterFront'

    water = Crafty.e('2D, WebGL, WaterSplashes')
      .attr(
        z: 30
        w: 32 * 25
        h: 32 * 5
        alpha: 0.3
      )
      .attr({
        waterRadius: 8
        minSplashDuration: 1700
        defaultWaterCooldown: 800
        waterSplashSpeed: 700
        minOffset: 2
        splashUpwards: false
      })

    @add(0, @level.visibleHeight - 330 + (5 * 32), water)

    p1hatch = Crafty.e('CarrierHatch')
    @add((5*32) + 100, @level.visibleHeight - 329 + (6*32), p1hatch)

    p2hatch = Crafty.e('CarrierHatch')
    @add((5*32) - 100, @level.visibleHeight - 329 + (6*32), p2hatch)

    @ship = Crafty.e('2D, Composable')
      .attr({ z: -13 })
      .compose(introShipComposition.introShip)
    @add(0, @level.visibleHeight - 116, @ship)

    @addElement 'water'
    @addElement 'waterHorizon'

    frontWave = Crafty.e('2D, WebGL, waterFront1, WaveFront').attr(
      z: 30
      w: ((@delta.x + Crafty.viewport.width * .5)) + 1
      h: 200
      lightness: 0.5
      #blur: 6.0
    ).crop(0, 1, 512, 95)
    @addBackground(0, @level.visibleHeight - 18, frontWave, 1.25)
    frontWave.waveY = 0

    @addElement 'cloud'

  enter: ->
    super
    @speed = @level._forcedSpeed
    @level.panCamera(y: 120, 0)
    @level.setForcedSpeed 0

    c = [
        type: 'delay'
        duration: 1000
      ,
        type: 'delay'
        duration: 600
        event: 'openHatch'
      ,
        type: 'linear'
        y: -80
        duration: 800
        easingFn: 'easeInOutQuad'
      ,
        event: 'lift'
        type: 'linear'
        x: 70
        y: -10
        easingFn: 'easeInQuad'
        duration: 600
      ,
        type: 'delay'
        duration: 1
        event: 'unlock'
      ,
        type: 'delay'
        duration: 1
        event: 'go'
    ]
    block = this
    leadAnimated = null

    fixOtherShips = (newShip) ->
      return unless leadAnimated
      return unless leadAnimated.has 'Choreography'
      newShip.attr(x: leadAnimated.x - 200, y: leadAnimated.y, z: -8)
      newShip.disableControl() if leadAnimated.disableControls
      newShip.addComponent 'Choreography'
      newShip.synchChoreography leadAnimated
      newShip.one 'ChoreographyEnd', ->
        @removeComponent 'Choreography', no
      newShip.one 'unlock', ->
        @enableControl()
        @weaponsEnabled = yes
      newShip.weaponsEnabled = leadAnimated.weaponsEnabled

    @bind 'ShipSpawned', fixOtherShips
    Crafty('PlayerControlledShip').each (index) ->
      return fixOtherShips(this) unless index is 0
      leadAnimated = this
      @addComponent 'Choreography'
      @attr x: 300 - (200 * index), y: Crafty.viewport.height - 50 - @h, z: -8
      @disableControl()
      @weaponsEnabled = no
      @choreography c
      @one 'ChoreographyEnd', =>
        @removeComponent 'Choreography', 'no'
        block.unbind 'ShipSpawned'
      @one 'unlock', ->
        @enableControl()
        @weaponsEnabled = yes
      @one 'openHatch', ->
        Crafty('CarrierHatch').each -> @open()
      @one 'lift', ->
        block.ship.addComponent('ShipSolid', 'BulletSolid')
        Crafty('CarrierHatch').each -> @close()
        Crafty('PlayerControlledShip').each ->
          @z = (@playerNumber - 1) * 10
        block.level.panCamera(y: -120, 2500)
      @one 'go', ->
        block.level.setForcedSpeed block.speed, accelerate: no

levelGenerator.defineBlock class extends CityScenery
  name: 'City.Ocean'
  delta:
    x: 1024
    y: 0

  generate: ->
    super
    @addElement 'cloud'
    @addElement 'cloud'
    @addElement 'waterHorizon'
    @addElement 'water'
    @addElement 'waterFront'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.CoastStart'
  delta:
    x: 1024
    y: 0
  autoNext: 'City.Coast'
  autoPrevious: 'City.Ocean'

  generate: ->
    super
    @addElement 'cloud'
    @addElement 'cityHorizon', 'start'
    @addElement 'water'
    @addElement 'waterFront'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.Coast'
  delta:
    x: 1024
    y: 0

  generate: ->
    super
    @addElement 'waterFront'
    @addElement 'cityHorizon'
    @addElement 'water'
    @addElement 'cloud'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.BayStart'
  delta:
    x: 1024
    y: 0
  autoNext: 'City.Bay'
  autoPrevious: 'City.Coast'

  generate: ->
    super
    @addElement 'cloud'
    @addElement 'cityHorizon'
    @addElement 'water'
    @addElement 'waterFront'
    @addElement 'cityStart'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.Bay'
  delta:
    x: 1024
    y: 0

  generate: ->
    super
    @addElement 'cloud'
    @addElement 'waterFront'
    @addElement 'water'
    @addElement 'cityHorizon'
    @addElement 'city'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.BayFull'
  delta:
    x: 1024
    y: 0

  generate: ->
    super
    @addElement 'cloud'
    @addElement 'waterFront'
    @addElement 'water'
    @addElement 'cityDistance'
    @addElement 'city'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.UnderBridge'
  delta:
    x: 1024
    y: 0
  autoNext: 'City.BayFull'

  generate: ->
    super
    @notifyOffsetX = -100

    @addElement 'waterFront', lightness: 0.8
    @addElement 'water'
    @addElement 'cityDistance'
    @addElement 'city-bridge'

    bridgeWidth = Crafty.viewport.width
    height = Crafty.viewport.height * 1.1

    # 2 front pillars

    @addBackground(0, 335,  @deck(.55, no, w: 550, z: -280), .55)
    @addBackground(0, 295,  @deck(.45, yes, w: 600, z: -270), .60)
    @addBackground(0, 255,  @deck(.35, no, w: 650, z: -260), .65)

    @addBackground(40, 290,  @pillar( .35, h: 200, z: -261), .65)
    @addBackground(870, 290,  @pillarX(.35, h: 200, z: -261), .65)

    @addBackground(0, 205,  @deck(.25, yes, w: 700, z: -50), .70)
    @addBackground(0, 155,  @deck(.15, no, w: 750, z: -40), .75)

    @addBackground(10, 180, @pillar( 0, h: 350, z: -31), .8)
    @addBackground(830, 180, @pillarX(0, h: 350, z: -31), .8)
    @addBackground(0, 95,  @deck(.05, yes, w: 800, z: -30), .8)

    @addBackground(0, 20,   @deck(0, no,  w: 900, z: -20).addComponent('BackDeck'), .9)

    dh = Crafty.e('2D, BulletSolid, ShipSolid, Collision, BridgeCeiling').attr(w: 1000, h: 30).origin('middle middle')
    @addBackground(0, -60, dh, 1.0)

    d1 = @deck(0, yes, w: 1000, z: -10).addComponent('MainDeck')

    @addBackground(0, -60, d1, 1.0)
    @addBackground(0, -180, @deck(0, no, w: 1200, z: 100, lightness: 0.6, blur: 0.0).addComponent('FrontDeck'), 1.2)

    p1 = @pillar( 0, h: 750, z: 80, lightness: 0.6, blur: 0.0).addComponent('TiltPillarLeft')
    p2 = @pillarX(0, h: 750, z: 80, lightness: 0.6, blur: 0.0).addComponent('TiltPillarRight')

    @addBackground(-20,  -60, p1, 1.2)
    @addBackground(834, -60, p2, 1.2)

    @bind 'BridgeDamage', once: yes, (level) ->
      get = (name) ->
        s = Crafty(name)
        s.get(s.length - 1)

      d0 = get('FrontDeck').addComponent('TweenPromise', 'Delta2D').sprite(16, 32)
      d1 = get('MainDeck').addComponent('TweenPromise', 'Delta2D').sprite(16, 32)
      d2 = get('BackDeck').addComponent('TweenPromise', 'Delta2D').sprite(16, 32)
      d0.half.sprite(16, 32)
      d1.half.sprite(16, 32)
      d2.half.sprite(16, 32)

      p1 = get('TiltPillarLeft').addComponent('TweenPromise', 'Delta2D').sprite(42, 29)
      p2 = get('TiltPillarRight').addComponent('TweenPromise', 'Delta2D').sprite(42, 29)
      dh = get('BridgeCeiling').addComponent('TweenPromise', 'Delta2D')

    @bind 'BridgeCollapse', once: yes, (level) =>
      get = (name) ->
        s = Crafty(name)
        s.get(s.length - 1)

      d0 = get('FrontDeck').addComponent('TweenPromise', 'Delta2D').sprite(16, 32)
      d1 = get('MainDeck').addComponent('TweenPromise', 'Delta2D').sprite(16, 32)
      d2 = get('BackDeck').addComponent('TweenPromise', 'Delta2D').sprite(16, 32)
      d0.half.sprite(16, 32)
      d1.half.sprite(16, 32)
      d2.half.sprite(16, 32)

      p1 = get('TiltPillarLeft').addComponent('TweenPromise', 'Delta2D').sprite(42, 29)
      p2 = get('TiltPillarRight').addComponent('TweenPromise', 'Delta2D').sprite(42, 29)
      dh = get('BridgeCeiling').addComponent('TweenPromise', 'Delta2D')

      WhenJS.sequence [
        ->
          WhenJS.parallel [
            -> level.setForcedSpeed 75, accelerate: yes
            -> d0.tweenPromise({ rotation: -12, dy: d0.dy + 100 }, 4000, 'easeInQuad')
            -> d1.tweenPromise({ rotation: -10, dy: d1.dy + 100 }, 4000, 'easeInQuad')
            -> dh.tweenPromise({ rotation: -10, dy: dh.dy + 100 }, 4000, 'easeInQuad')
            -> d2.tweenPromise({ rotation: -7, dy: d2.dy + 100 }, 4000, 'easeInQuad')
            -> p1.tweenPromise({ rotation: -7, dy: p1.dy + 100 }, 3000, 'easeInQuad')
            -> p2.tweenPromise({ rotation: 7 }, 3000, 'easeInQuad')
          ]
        ->
          WhenJS.parallel [
            -> level.setForcedSpeed 300, accelerate: yes
            -> d0.tweenPromise({ dy: d0.dy + 400 }, 4000, 'easeInQuad')
            -> d1.tweenPromise({ dy: d1.dy + 430 }, 4000, 'easeInQuad')
            -> dh.tweenPromise({ dy: dh.dy + 430 }, 4000, 'easeInQuad')
            -> d2.tweenPromise({ dy: d2.dy + 400 }, 4000, 'easeInQuad')
            -> p1.tweenPromise({ rotation: -27, dy: p1.dy + 300 }, 3000, 'easeInQuad')
            -> p2.tweenPromise({ rotation: 27, dy: p2.dy + 200 }, 3000, 'easeInQuad')
          ]
      ]

  leave: ->
    super
    @unbind('BridgeDamage')
    @unbind('BridgeCollapse')

  deck: (gradient, flipped, attr) ->
    aspectR = 1024 / 180
    attr.h = attr.w / aspectR
    color = if flipped then '#2ba04c' else '#b15a5a'
    result = Crafty.e('2D, WebGL, bridgeDeck, Horizon, SunBlock, SpriteAnimation')
      .crop(0, 2, 511, 180)
      .attr(extend(attr, w: attr.w / 2))
      .saturationGradient(gradient, gradient)
      .colorOverride color, 'partial'

    part2 = Crafty.e('2D, WebGL, bridgeDeck, Horizon, SunBlock, SpriteAnimation')
      .crop(0, 2, 511, 180)
      .saturationGradient(gradient, gradient)
      .flip('X')
      .colorOverride color, 'partial'
    part2.attr(extend(attr,
      x: result.x + result.w
      y: result.y
      z: result.z
      w: result.w
      h: result.h
    ))
    result.half = part2
    result.attach part2
    result.origin(result.h / 2, result.w * 2)

    result

  pillar: (gradient, attr) ->
    aspectR = 180 / 534
    attr.w = attr.h * aspectR
    attr.h = attr.h
    Crafty.e('2D, WebGL, bridgePillar, Horizon, SunBlock')
      .crop(2, 0, 180, 534)
      .attr(attr)
      .saturationGradient(gradient, gradient)

  pillarX: (gradient, attr) ->
    @pillar(gradient, attr).flip('X')


levelGenerator.defineBlock class extends CityScenery
  name: 'City.Skyline'
  delta:
    x: 1024
    y: 0

  generate: ->
    super

    @addElement 'cityFrontTop'
    @addElement 'cityFrontBlur'
    @addElement 'cityDistance'
    @addElement 'cityNoCollision'

levelGenerator.defineBlock class extends CityScenery
  name: 'City.SkylineBase'
  delta:
    x: 1024
    y: 0
  autoNext: 'City.Skyline2'

  generate: ->
    super
    @addElement 'cityFront'
    h = 400 + 200

    e = Crafty.e('2D, WebGL, cityDistanceBaseTop, SunBlock, Horizon')
      .colorDesaturation(Game.backgroundColor)
      .saturationGradient(.9, .6)
      .crop(1, 1, 255, 223)
      .attr(z: -598, w: 256)

    @addBackground(0, @level.visibleHeight - 225 - 16 - 127, e, .25)

    eb = Crafty.e('2D, WebGL, cityDistanceBaseBottom, MiliBase, SunBlock, Horizon')
      .colorDesaturation(Game.backgroundColor)
      .saturationGradient(.9, .6)
      .crop(1, 1, 255, 127)
      .attr(z: -598, w: 256)

    @addBackground(0, @level.visibleHeight - 225 - 16 + 96, eb, .25)

    @addElement 'city'

    h = 400 + 300
    @add(0, @level.visibleHeight - 100, Crafty.e('2D, WebGL, Color, SunBlock').attr(w: @delta.x, h: h, z: -10).color('#505050'))

levelGenerator.defineBlock class extends CityScenery
  name: 'City.Skyline2'
  delta:
    x: 1024
    y: 0

  generate: ->
    super
    @addElement 'cityFront'
    @addElement 'cityFront', 4, 512, 'bigBuildingBottom2'

    @addElement 'water'
    @addElement 'cityDistance'

    @addElement 'city'

    h = 160
    @add(0, @level.visibleHeight - 100, Crafty.e('2D, WebGL, Color, SunBlock').attr(w: @delta.x, h: h, z: -25).color('#555'))
    h2 = 10
    @add(0, @level.visibleHeight - 100 + h, Crafty.e('2D, WebGL, Color, SunBlock').attr(w: @delta.x, h: h2, z: -25).color('#777'))
    h3 = 400
    @add(0, @level.visibleHeight - 100 + h + h2, Crafty.e('2D, WebGL, Color, SunBlock').attr(w: @delta.x, h: h3, z: -25).color('#333'))
    h3 = 40
    @add(0, @level.visibleHeight + 170 - h3, Crafty.e('2D, ShipSolid, BulletSolid').attr(w: @delta.x, h: h3, z: 2))

levelGenerator.defineBlock class extends LevelScenery
  name: 'City.TrainTunnel'
  delta:
    x: 1024
    y: 0

  generate: ->
    super

    h = 150
    @add(0, @level.visibleHeight - 100, Crafty.e('2D, WebGL, Color, SunBlock, ShipSolid, BulletSolid').attr(w: @delta.x, h: h, z: -10).color('#505050'))
    h2 = 400
    @add(0, @level.visibleHeight - 100 + h, Crafty.e('2D, WebGL, Color, SunBlock').attr(w: @delta.x, h: h2, z: -10).color('#202020'))
    h = 150
    @add(0, @level.visibleHeight - 100 + h + h2, Crafty.e('2D, WebGL, Color, ShipSolid, BulletSolid, SunBlock').attr(w: @delta.x, h: h + h2, z: -10).color('#505050'))

levelGenerator.defineBlock class extends LevelScenery
  name: 'City.SmallerTrainTunnel'
  delta:
    x: 1024
    y: 0

  generate: ->
    super
    h = 250
    @add(0, @level.visibleHeight - 100, Crafty.e('2D, WebGL, Color, SunBlock, ShipSolid, BulletSolid').attr(w: @delta.x, h: h, z: -10).color('#505050'))
    h2 = 300
    @add(0, @level.visibleHeight - 100 + h, Crafty.e('2D, WebGL, Color, SunBlock').attr(w: @delta.x, h: h2, z: -10).color('#202020'))
    h3 = 350
    @add(0, @level.visibleHeight - 100 + h + h2, Crafty.e('2D, WebGL, Color, ShipSolid, BulletSolid, SunBlock').attr(w: @delta.x, h: h3, z: -10).color('#505050'))
