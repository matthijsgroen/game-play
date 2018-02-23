{ EntityScript } = require('src/lib/LazerScript')
{ MineCannonInActive, MineCannonActive } = require('./mine_cannon')
{ DroneShipCore } = require('./drone_ship_core');
{ TurretInActive, TurretActive } = require('./turret')
{ Swirler, Shooter, CrewShooters, Stalker, ScraperFlyer, DroneFlyer } = require('../stage1/army_drone')
{ HeliInactive, HeliFlyAway, HeliAttack } = require('./heli_attack')

console.log(DroneShipCore)
class Cabin1Inactive extends EntityScript
  spawn: (options) ->
    Crafty.e('FirstShipCabin, KeepAlive')
      .shipCabin()
      .sendToBackground(1.0, -8)

  execute: ->
    @invincible yes

class Cabin1Active extends EntityScript
  spawn: (options) ->
    item = Crafty('FirstShipCabin').get(0)
    if item and item.health > 10
      item.reveal()
      return item
    Crafty.e('FirstShipCabin, KeepAlive')
      .shipCabin()
      .sendToBackground(1.0, -8)

  onKilled: ->
    @deathDecoy()

  execute: ->
    @bindSequence 'Destroyed', @onKilled
    @sequence(
      @invincible no
      @wait(20000)
    )

class Cabin2Inactive extends EntityScript
  spawn: (options) ->
    Crafty.e('SecondShipCabin, KeepAlive')
      .shipCabin()
      .sendToBackground(1.0, -8)

  execute: ->
    @invincible yes

class Cabin2Active extends EntityScript
  spawn: (options) ->
    item = Crafty('SecondShipCabin').get(0)
    if item and item.health > 10
      item.reveal()
      return item
    Crafty.e('SecondShipCabin, KeepAlive')
      .shipCabin()
      .sendToBackground(1.0, -8)

  onKilled: ->
    @deathDecoy()

  execute: ->
    @bindSequence 'Destroyed', @onKilled
    @sequence(
      @invincible no
      @wait(20000)
    )

class ShipBoss extends EntityScript

  spawn: (options) ->
    Crafty.e('BattleShip').attr(
      x: Crafty.viewport.width + 180
      y: 400
      defaultSpeed: options.speed ? 85
    ).ship()
    # .setSealevel(@level.visibleHeight - 10)

  getPath: (pattern) ->
    return [
      [.156, .5]
      [.5, .833]
      [.86, .52]

      [.5, .21]
      [.156, .5]
      [.5, .833]
      [.86, .52]

      [-20, .21]
    ]

  randomAmountSpawnedDrones: ->
    console.log(Math.round(Math.random() * 5))
    return Math.round(Math.random() * 5)

  placeEnemiesOnShip: ->
    @sequence(
      @placeSquad Cabin1Inactive,
        options:
          attach: 'Cabin1Place'
      @placeSquad Cabin2Inactive,
        options:
          attach: 'Cabin2Place'
      @placeSquad HeliInactive,
        amount: 2
        delay: 0
        options:
          attach: 'HeliPlace'
      @placeSquad DroneShipCore,
        options:
          attach: 'DroneShipCorePlace'
    )

  executeStageOne: ->
    @sequence(
      @moveTo(x: 0.8, easing: "easeInOutQuad")
    )

  releaseDronesFromHatchOne: (dronePattern) ->
    @sequence(
      @action 'open1'
      @wait(500)
      @parallel(
        # Place Turret lqter

        # @placeSquad DroneFlyer,
        #   amount: 5,
        #   delay: 500
        #   options:
        #     startAt: 'ShipHatch1'
        #     hatchReveal: 'ShipHatch1'
        #     dx: 25
        #     dy: 20
        #     debug: true,
        #     path: @getPath(dronePattern)
        @sequence(
          @wait(1200)
          @action 'close1'
        )
      )
    )

  releaseDronesFromHatchTwo: (dronePattern) ->
    @sequence(
      @action 'open2'
      @wait(500)
      @parallel(
        @placeSquad DroneFlyer,
          amount: 8,
          delay: 500
          options:
            startAt: 'ShipHatch2'
            hatchReveal: 'ShipHatch2'
            dx: 25
            dy: 20
            debug: true,
            path: @getPath(dronePattern)
        @sequence(
          @wait(1200)
          @action 'close2'
        )
      )
    )

  executeStageTwo: ->
    @sequence(
      @moveTo(x: -0.1, easing: "easeInOutQuad")
      @while(
        # @placeSquad TurretActive,
        #   options:
        #     attach: 'TurretPlace'
        @lazy(
          @releaseDronesFromHatchOne,
          -> Math.round(Math.random() * 3 + 1)
        )
      )
    )

  executeStageThree: ->
    @while(
      @placeSquad TurretActive,
        options:
          attach: 'TurretPlace'
          attachOffset: 1
      @lazy(
        @releaseDronesFromHatchTwo,
        -> Math.round(Math.random() * 3 + 1)
      )
    )

  executeStageFour: ->
    @sequence(
      @moveTo(x: 0.1, easing: "easeInOutQuad")
      @while(
        @placeSquad Cabin1Active,
          options:
            attach: 'Cabin1Place'
        @lazy(
          @releaseDronesFromHatchOne,
          -> Math.round(Math.random() * 3 + 1)
        )
      )
    )

  executeStageFive: ->
    @sequence(
      @parallel(
        @moveTo(x: -0.2, easing: "easeInOutQuad")
        @placeSquad HeliFlyAway,
          amount: 2
          delay: 1000
      )
      @parallel(
        @placeSquad HeliAttack,
          options:
            speed: 80
            path: [
              [.9, .6]
              [.7, .45]
              [.55, .4]
              [.4, .6]
              [.6, .8]
              [.8, .6]
              [.4, .8]
              [.2, .4]
              [-.2, .7]
            ]
        @placeSquad HeliAttack,
          options:
            speed: 80
            path: [
              [.9, .3]
              [.7, .25]
              [.55, .2]
              [.4, .4]
              [.6, .3]
              [.8, .3]
              [.4, .6]
              [.2, .3]
              [-.2, .4]
            ]
        @moveTo(x: -0.5, easing: "easeInOutQuad", speed: 30)
      )
    )

  executeStageSix: ->
    @sequence(
      @parallel(
        @while(
          @placeSquad Cabin2Active,
            options:
              attach: 'Cabin2Place'
          @lazy(
            @releaseDronesFromHatchTwo,
            -> Math.round(Math.random() * 3 + 1)
          )
        )
      )
      @moveTo(x: -0.6, easing: "easeInOutQuad")
      @while(
        @sequence(
          @moveTo(y: 450, easing: "easeInOutQuad", speed: 20)
          @moveTo(x: -1.40, easing: "easeInOutQuad")
        )
        @sequence(
          @smallExplosion(offsetX: 600, offsetY: -50)
          @smallExplosion(offsetX: 500, offsetY: -20)
          @wait(300)
        )
      )
    )

  execute: ->
    # Start stage 1
    @sequence(
      @lazy @placeEnemiesOnShip
      @lazy @executeStageOne
      @lazy @executeStageTwo
      @lazy @executeStageThree
      @lazy @executeStageFour
      @lazy @executeStageFive
      @lazy @executeStageSix
    )

module.exports =
  default: ShipBoss
