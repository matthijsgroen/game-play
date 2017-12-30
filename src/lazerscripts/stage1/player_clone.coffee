{ EntityScript } = require('src/lib/LazerScript')
{ Stage1BossAimedRocket, Stage1BossBombRaid } = require('./stage1boss')

class PlayerClone extends EntityScript
  assets: ->
    @loadAssets('playerShip')

  spawn: (options) ->
    @dir = options.from ? 'top'

    p = Crafty.e('PlayerClone').attr(
      x: Crafty.viewport.width + 40
      y: .1 * Crafty.viewport.height
      defaultSpeed: options.speed ? 280
    ).playerClone(
      pointsOnHit: 25
      pointsOnDestroy: 125
    )
    p.addComponent('ShootOnSight').shootOnSight
      cooldown: 150
      sightAngle: 20
      projectile: (x, y, angle) =>
        projectile = Crafty.e('Sphere, Hostile, Projectile').attr(
          w: 9
          h: 9
          speed: 600
          damage: 1
        ).blink()
        projectile.shoot(x, y, angle)
    p

  execute: ->
    @bindSequence 'Destroyed', @onKilled

    @sequence(
      @while(
        @flightPathTop()
        @sequence(
          @dropBombs()
          @wait 300
        )
      )
      @turnAround()
      @while(
        @flightPathBack()
        @sequence(
          @dropBombs()
          @wait 300
        )
      )
      @turnAround()
      @while(
        @flightPathTop()
        @sequence(
          @dropBombs()
          @wait 300
        )
      )
    )

  flightPathTop: ->
    @moveTo x: -.1, y: .2

  flightPathBack: ->
    @moveTo x: 1.01, y: .1

  onKilled: ->
    @sequence(
      @deathDecoy()
      @smallExplosion(offsetX: 20, offsetY: 30)
      @wait 50
      @smallExplosion(offsetX: 40, offsetY: 20)
      @wait 50
      @smallExplosion(offsetX: -50, offsetY: -10)
      @wait 20
      @endDecoy()
      @bigExplosion(damage: 0)
    )

  dropBombs: ->
    @async @placeSquad(Stage1BossBombRaid,
      options:
        location: @location()
        armed: no
        scale: .75
    )


  fireRockets: (amount) ->
    script = Stage1BossAimedRocket

    @sequence(
      @async @placeSquad(script,
        options:
          z: 5
          offsetX: 0
          offsetY: 50
          scale: .75
          cooldown: 20
          health: 100
          location: @location()
      )
      @async @placeSquad(script,
        options:
          z: -5
          offsetX: 0
          offsetY: -50
          cooldown: 20
          scale: .75
          health: 100
          location: @location()
      )
    )

module.exports =
  default: PlayerClone