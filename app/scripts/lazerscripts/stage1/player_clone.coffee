Game = @Game
Game.Scripts ||= {}

class Game.Scripts.PlayerClone extends Game.EntityScript
  spawn: (options) ->
    dir = options.from ? 'top'
    switch dir
      when 'top'
        startY = .1
        @endY = 1.1
      when 'middle'
        startY = .5
        @endY = .5
      else
        startY = .8
        @endY = -.1
    p = Crafty.e('Enemy, Color').attr(
      x: Crafty.viewport.width + 40
      y: startY * Crafty.viewport.height
      speed: options.speed ? 100
      health: 900
      w: 30
      h: 30
      weaponOrigin: [0, 15]
    ).enemy().color('#FF0000')
    p.addComponent('BurstShot').burstShot
      projectile: (x, y, angle) =>
        projectile = Crafty.e('Projectile, Color, Enemy').attr(
          w: 16
          h: 4
          speed: 550
        ).color('#FFFF00')
        projectile.shoot(x, y, angle)
    p

  execute: ->
    @bindSequence 'Destroyed', @onKilled

    @moveTo x: -.1, y: @endY

  onKilled: ->
    @bigExplosion()
