{ EntityScript } = require('src/lib/LazerScript')

class SplashJumper extends EntityScript

  spawn: ->
    Crafty.e('Drone').drone(
      health: 200
      x: 680
      y: 200
      defaultSpeed: 300
    )

  execute: ->
    @bindSequence 'Destroyed', @onKilled
    @sequence(
      @moveTo x: 500
      @wait 500
      @repeat @sequence(
        @moveTo y: 600
        @moveTo y: 50
      )
    )

  onKilled: ->
    @explosion(@location())

module.exports =
  default: SplashJumper