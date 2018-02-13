{ EntityScript } = require('src/lib/LazerScript')
MineCannon = require('./mine_cannon').default
{ TurretInActive, TurretActive } = require('./turret')
{ Swirler, Shooter, CrewShooters, Stalker, ScraperFlyer } = require('../stage1/army_drone')

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
      defaultSpeed: options.speed ? 45
    )
    # .setSealevel(@level.visibleHeight - 10)

  execute: ->
    # Start stage 1
    @sequence(
      @parallel(
        @placeSquad MineCannon,
          options:
            amount: 1
            attach: 'MineCannonPlace'
        @placeSquad Cabin1Inactive,
          options:
            attach: 'Cabin1Place'
        @placeSquad Cabin2Inactive,
          options:
            attach: 'Cabin2Place'
        @placeSquad MineCannon,
          options:
            amount: 1
            attach: 'MineCannonPlace'
        @placeSquad TurretInActive, # Turret
          amount: 1
          delay: 0
          options:
            attach: 'TurretPlace'

        @moveTo(x: 0.8)
      )
      # If parallel has resolved, move on to the next block
      #
      # Start stage 2

      @moveTo(x: -0.1)
      @sequence(
        @parallel(
          # open hatch 1
          @action 'open1'
          @placeSquad Shooter,
            amount: 10,
            delay: 400
            options: {
              startAt: 'ShipHatch1'
              hatchReveal: 'ShipHatch1'
              dx: 25
              dy: 20
            }

          # ACTIVATE TURRET HERE
          @placeSquad TurretActive, # Turret
            amount: 1
            delay: 0
            options:
              attach: 'TurretPlace'

        )


        # @sequence(
        #   @placeSquad Swirler,
        #     amount: 4
        #     delay: 200
        #   @wait(3000)
        #   @parallel(
        #     # Open hatch 1
        #     @action 'open1'
        #     @placeSquad Shooter,
        #       amount: 9,
        #       delay: 400
        #       options: {
        #         startAt: 'ShipHatch1'
        #         hatchReveal: 'ShipHatch1'
        #         dx: 25
        #         dy: 20
        #       }
        #     @sequence(
        #       @wait(3000)
        #       @placeSquad Shooter,
        #         amount: 5,
        #         delay: 200
        #         options: {
        #           startAt: 'ShipHatch1'
        #           hatchReveal: 'ShipHatch1'
        #           dx: 25
        #           dy: 20
        #         }
        #       @wait(2000)
        #       @placeSquad Shooter,
        #         amount: 7,
        #         delay: 600
        #         options: {
        #           startAt: 'ShipHatch1'
        #           hatchReveal: 'ShipHatch1'
        #           dx: 25
        #           dy: 20
        #         }
        #       # close hatch 1
        #       @action 'close1'
        #       @moveTo(x: -2)
        #     )
        #     @wait(2000)
        #   )
        #   @sequence(
        #     # open hatch 2
        #     @action 'open2'
        #
        #     @parallel(
        #       @placeSquad Shooter,
        #         amount: 3,
        #         delay: 200
        #         options: {
        #           startAt: 'ShipHatch2'
        #           hatchReveal: 'ShipHatch2'
        #           dx: 25
        #           dy: 20
        #         }
        #       @placeSquad CrewShooters,
        #         amount: 8,
        #         delay: 200
        #         options: {
        #           x: 115
        #           y: -900
        #         }
        #
        #       @placeSquad Shooter,
        #         amount: 3,
        #         delay: 200
        #         options: {
        #           startAt: 'ShipHatch2'
        #           hatchReveal: 'ShipHatch2'
        #           dx: 25
        #           dy: 20
        #         }
        #       @placeSquad ScraperFlyer,
        #         amount: 8,
        #         delay: 700
        #         options: {
        #           x: 915
        #           y: 0
        #         }
        #     )
        #
        #     @action 'close2'
        #     @sequence(
        #       @parallel(
        #         @moveTo(x: -1.5) # Move the boat out of view
        #         @placeSquad CrewShooters,
        #           amount: 12,
        #           delay: 100
        #           options: {
        #             x: 515
        #             y: 0
        #           }
        #       )
        #
        #     )
        #
        #     # Boat moves but somehow doesn't show enemies yet.
        #     # TO FIX!!
        #     @placeSquad CrewShooters,
        #       amount: 2,
        #       delay: 100
        #       options: {
        #         x: 515
        #         y: 0
        #       }
        #     @placeSquad CrewShooters,
        #       amount: 12,
        #       delay: 600
        #       options: {
        #         x: 515
        #         y: 0
        #       }
        #     @parallel(
        #       @moveTo(x: -2) # move back!
        #       # Show some aircrafts here
        #       @placeSquad Shooter,
        #         amount: 8,
        #         delay: 600
        #         options: {
        #           x: -15
        #           y: 100
        #         }
        #
        #       @placeSquad Swirler,
        #         amount: 6,
        #         delay: 200
        #         options: {
        #           x: -15
        #           y: 100
        #         }
        #     )
        #     @action 'open2'
        #     @placeSquad Shooter, # 2
        #       amount: 6,
        #       delay: 200
        #       options: {
        #         startAt: 'ShipHatch2'
        #         hatchReveal: 'ShipHatch2'
        #         dx: 25
        #         dy: 20
        #       }
        #     @action 'open1'
        #     @placeSquad Shooter, # 1
        #       amount: 3,
        #       delay: 200
        #       options: {
        #         startAt: 'ShipHatch1'
        #         hatchReveal: 'ShipHatch1'
        #         dx: 25
        #         dy: 20
        #       }
        #     @wait(1000)
        #       @parallel(
        #         @placeSquad Shooter, # 1
        #           amount: 6,
        #           delay: 200
        #           options: {
        #             startAt: 'ShipHatch1'
        #             hatchReveal: 'ShipHatch1'
        #             dx: 25
        #             dy: 20
        #           }
        #         @placeSquad Shooter, # 2
        #           amount: 6,
        #           delay: 200
        #           options: {
        #             startAt: 'ShipHatch2'
        #             hatchReveal: 'ShipHatch2'
        #             dx: 25
        #             dy: 20
        #           }
        #       )
        #       @wait(1000)
        #       @action 'close1'
        #       @placeSquad Shooter, # 2
        #         amount: 7,
        #         delay: 900
        #         options: {
        #           x: 565
        #           y: Crafty.viewport.height + 100
        #         }
        #       @wait(1000)
        #       @action 'close2'
        #
        #     @wait(5000)
        #     @moveTo(x: -5) # move forward!
        #
        #
        #   )
        #
        # )
      )
    )

module.exports =
  default: ShipBoss
