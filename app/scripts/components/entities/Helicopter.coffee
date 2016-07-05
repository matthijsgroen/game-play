Crafty.c 'Helicopter',
  init: ->
    @requires 'Enemy, helicopter, SpriteAnimation'
    @reel 'fly', 200, [[0, 6, 4, 2], [4, 6, 4, 2]]
    @crop 0, 0, 120, 50
    @origin 'center'

  helicopter: (attr = {}) ->
    defaultHealth = 2000
    @attr _.defaults(attr,
      w: 120,
      h: 50,
      health: defaultHealth
      maxHealth: attr.health ? defaultHealth
      weaponOrigin: [5, 46]
    )
    @origin 'center'
    @flip('x')
    @animate 'fly', -1
    #@colorOverride '#808080', 'partial'

    @enemy()
    @bind 'Hit', (data) =>
      if data.projectile.has('Bullet')
        @shiftedX += 2
        Crafty.audio.play('hit', 1, .5)
        Crafty.e('Blast, LaserHit').explode(
          x: data.projectile.x
          y: data.projectile.y
          radius: 4
          duration: 50
        )

    this

  updatedHealth: ->
    #sprite = 0
    #healthPerc = @health / @maxHealth
    #sprite = 2 if healthPerc < .3
    #@sprite(0, sprite)

  updateMovementVisuals: (rotation, dx, dy, dt) ->
    @vx = dx * (1000 / dt)
    @vy = dy * (1000 / dt)

