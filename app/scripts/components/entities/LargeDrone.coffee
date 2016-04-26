Crafty.c 'LargeDrone',
  init: ->
    @requires 'Enemy, standardLargeDrone, SpriteAnimation'

  drone: (attr = {}) ->
    defaultHealth = 360000
    @attr _.defaults(attr,
      w: 90
      h: 70
      health: defaultHealth
      maxHealth: attr.health ? defaultHealth
      z: -1
    )
    @origin 'center'
    @collision [2, 36, 16,15, 86,2, 88,4, 62,15, 57,46, 46, 66, 18, 66, 3, 47]

    @eye = Crafty.e('2D, WebGL, eyeStart, SpriteAnimation')
    @attach(@eye)
    @eye.attr(x: 2 + @x, y: 18 + @y, z: 1)
    @eye.reel 'slow', 1500, [[0, 3], [1, 3], [2, 3], [3, 3], [0, 4], [1, 4], [2, 4], [3, 4]]

    @wing = Crafty.e('2D, WebGL, wingLoaded, SpriteAnimation')
    @attach(@wing)
    @wing.attr(x: 22 + @x, y: 33 + @y, z: 1, h: 21, w: 46)
    @wing.reel 'emptyWing', 30, [[6, 4]]
    @wing.reel 'reload', 500, [[2, 4], [3, 4], [4, 4], [5, 4]]

    @enemy()
    @onHit 'Mine', (e) ->
      return if Game.paused
      return if @hidden
      for c in e
        mine = c.obj
        return if mine.hidden
        return if mine.z < 0
        mine.absorbDamage(300) # Mine collision on LargeDrone triggers explosion of mine
    @updatedHealth()
    @bind 'Hit', (data) =>
      if data.projectile.has('Bullet')
        @shiftedX += 1
        Crafty.audio.play('hit', 1, .5)
        Crafty.e('Blast, LaserHit').explode(
          x: data.projectile.x
          y: data.projectile.y
          z: @z + 2
          radius: 4
          duration: 50
        )
    this

  healthBelow: (perc) ->
    (@health / @maxHealth) < perc

  updatedHealth: ->
    sprite = 0
    healthPerc = @health / @maxHealth
    sprite = 1 if healthPerc < .9
    sprite = 2 if healthPerc < .6
    sprite = 3 if healthPerc < .3
    @sprite(sprite, 0)

  updateMovementVisuals: (rotation, dx, dy, dt) ->
    @vx = dx * (1000 / dt)
    @vy = dy * (1000 / dt)
