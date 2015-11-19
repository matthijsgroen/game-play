Game = @Game
Game.ScriptModule ?= {}

# Actions to control an entity in the game
#
# - bindSequence
# - sendToBackground
# - reveal
# - movePath
# - moveTo
# - rotate
# - synchronizeOn
# - location
# - pickTarget
# - targetLocation
#
Game.ScriptModule.Entity =
  # Change the execution sequence when the bound entity fires a trigger.
  #
  # You can use this to:
  # - Show an explosion when an enemy is killed
  # - Change the behaviour of an enemy when his health is below a certain point
  # - Let a barrel drop when touched
  #
  # example:
  #
  # @bindSequence 'Destroyed', @onKilled
  # @bindSequence 'Hit', @fase2, => @entity.health < 140000
  #
  # When the new sequence is triggered, the event is unbound from
  # the entity. So the sequence will always be started once. When a new
  # sequence is started, a current running one will be aborted.
  bindSequence: (eventName, sequenceFunction, filter) ->
    return unless sequenceFunction?
    filter ?= -> true
    eventHandler = (args...) =>
      return unless filter(args...)
      @entity.unbind(eventName, eventHandler)
      p = (sequence) =>
        @alternatePath = null
        WhenJS(sequenceFunction.apply(this, args)(sequence)).catch =>
          @alternatePath

      @currentSequence = sequence = Math.random()
      @alternatePath = p(sequence)
    @entity.bind(eventName, eventHandler)

  # remove an entity from the current gameplay. This means it cannot shoot
  # the player, and the player cannot shoot the entity. This is useful
  # for moving entities behind scenery.
  sendToBackground: (scale, z) ->
    (sequence) =>
      @_verify(sequence)
      @entity.sendToBackground(scale, z)

  reveal: ->
    (sequence) =>
      @_verify(sequence)
      d = WhenJS.defer()
      scale = @entity.scale
      duration = Math.abs(1.0 - scale) * 1000
      targetW = @entity.w / scale
      targetH = @entity.h / scale

      @entity.choreography([
        type: 'tween'
        properties:
          scale: 1.0
          w: targetW
          h: targetH
        duration: duration
      ]).one 'ChoreographyEnd', =>
        @entity.reveal()
        d.resolve()
      d.promise

  # Move an entity through a set of coordinates (relative to the viewport)
  # in a bezier path. By default the entity moves with its own 'speed' property
  # but can be overridden with settings.
  #
  # example:
  #
  # @movePath [
  #   [320, 100]
  #   [100, 240]
  #   [320, 400]
  #   [550, 250]
  #   [-10, 100]
  # ]
  #
  # extra settings supported:
  # - speed: override the speed of the entity (in px/sec)
  # - rotate: yes/no should the entity rotate along the path?
  # - skip: amount of milliseconds to skip in this animation
  movePath: (path, settings = {}) ->
    (sequence) =>
      @_verify(sequence)
      return unless @enemy.alive
      settings = _.defaults(settings,
        rotate: yes
        skip: 0
      )
      path.unshift [
        @entity.x + Crafty.viewport.x
        @entity.y + Crafty.viewport.y
      ]

      pp = path[0]
      d = 0
      bezierPath = (for p in path
        [x, y] = p
        [px, py] = pp
        a = Math.abs(x - px)
        b = Math.abs(x - py)
        c = Math.sqrt(a**2 + b**2)
        d += c
        pp = p
        { x: x - Crafty.viewport.x, y: y - Crafty.viewport.y }
      )
      duration = (d / @entity.speed) * 1000

      defer = WhenJS.defer()
      @entity.choreography(
        [
          type: 'viewportBezier'
          rotation: settings.rotate
          path: bezierPath
          duration: duration
        ], compensateCameraSpeed: yes, skip: settings.skip
      ).one('ChoreographyEnd', ->
        defer.resolve()
      )
      defer.promise

  # Moves the entity to a coordinate
  # the provided coordinate can also be a function (that does not take arguments)
  # that returns an object with an 'x' and an 'y'.
  #
  # This method moves an entity below water if the Y gets below the 'seaLevel'
  #
  # extra settings can be provided:
  # - speed: override the default speed of the entity (in px/sec)
  moveTo: (location, extraSettings = {}) ->
    (sequence) =>
      @_verify(sequence)
      return unless @enemy.alive
      settings = location?() ? location
      _.extend(settings, extraSettings)

      seaLevel = @_getSeaLevel()

      if @enemy.moveState is 'air'
        if settings.y? and settings.y > seaLevel + Crafty.viewport.y
          airSettings = _.clone settings
          airSettings.y = seaLevel
          return @_moveAir(airSettings)
            .then =>
              @enemy.moveState = 'water'
              if @enemy.alive
                @_setupWaterSpot()
                @_waterSplash()
                @_moveWater(settings)
        else
          return @_moveAir(settings)

      if @enemy.moveState is 'water'
        if settings.y? and settings.y < seaLevel + Crafty.viewport.y
          waterSettings = _.clone settings
          waterSettings.y = seaLevel
          return @_moveWater(waterSettings)
            .then =>
              @enemy.moveState = 'air'
              if @enemy.alive
                @_removeWaterSpot()
                @_waterSplash()
                @_moveAir(settings)
        else
          return @_moveWater(settings)

  _setupWaterSpot: ->
    waterSpot = Crafty.e('2D, Canvas, Color, Choreography, Tween')
      .color('#000040')
      .attr(
        w: @entity.w + 10
        x: @entity.x - 5
        y: @entity.y
        h: 20
        alpha: 0.7
        z: @entity.z - 1
      )
    if @entity.has('ViewportFixed')
      waterSpot.addComponent('ViewportFixed')
    @entity.hide(waterSpot)

  _removeWaterSpot: ->
    @entity.reveal()

  _waterSplash: ->
    defer = WhenJS.defer()
    Crafty.e('WaterSplash').waterSplash(
      x: @entity.x
      y: @entity.y
      size: @entity.w
    ).one 'ParticleEnd', ->
      defer.resolve()

    defer.promise

  _moveWater: (settings) ->
    defaults =
      speed: @entity.speed

    if @entity.has('ViewportFixed')
      defaults.x = @entity.x + Crafty.viewport.x
      defaults.y = @entity.y + Crafty.viewport.y

    seaLevel = @_getSeaLevel()
    settings = _.defaults(settings, defaults)
    surfaceSize =
      w: @entity.w + 10
      #x: @entity.x - 5
      y: seaLevel
      h: 20
      alpha: 0.7
    maxSupportedDepth = 700
    maxDepthSize =
      w: @entity.w * .3
      #x: @entity.x + (@entity.w * .3)
      y: @entity.hideMarker.y + 15
      h: 5
      alpha: 0.2

    deltaX = if settings.x? then Math.abs(settings.x - (@entity.hideMarker.x + Crafty.viewport.x)) else 0
    deltaY = if settings.y? then Math.abs(settings.y - (@entity.hideMarker.y + Crafty.viewport.y)) else 0
    delta = Math.sqrt((deltaX ** 2) + (deltaY ** 2))
    duration = (delta / settings.speed) * 1000

    if settings.y?
      depth = Math.min(settings.y, maxSupportedDepth)
      v = (depth - seaLevel) / (maxSupportedDepth - seaLevel)

      depthProperties = {}

      for k, p of surfaceSize
        depthProperties[k] = (1 - v) * p + (v * maxDepthSize[k])

      @entity.hideMarker.tween depthProperties, duration

    defer = WhenJS.defer()
    @entity.attr(
      x: settings.x - Crafty.viewport.x
      y: settings.y - Crafty.viewport.y
    )

    type = if @entity.has('ViewportFixed')
      'viewport'
    else
      settings.x = deltaX
      settings.y = deltaY
      'linear'

    @entity.hideMarker.choreography([
      type: type
      x: settings.x
      maxSpeed: settings.speed
      duration: duration
    ]).one('ChoreographyEnd', ->
      defer.resolve()
    )
    defer.promise

  _getSeaLevel: ->
    220 + (220 * (@entity.scale ? 1.0))

  _moveAir: (settings) ->
    defaults =
      speed: @entity.speed

    if @entity.has('ViewportFixed')
      defaults.x = @entity.x + Crafty.viewport.x
      defaults.y = @entity.y + Crafty.viewport.y

    settings = _.defaults(settings, defaults)

    deltaX = if settings.x? then Math.abs(settings.x - (@entity.x + Crafty.viewport.x)) else 0
    deltaY = if settings.y? then Math.abs(settings.y - (@entity.y + Crafty.viewport.y)) else 0
    delta = Math.sqrt((deltaX ** 2) + (deltaY ** 2))

    defer = WhenJS.defer()
    type = if @entity.has('ViewportFixed')
      'viewport'
    else
      settings.x = deltaX
      settings.y = deltaY
      'linear'

    @entity.choreography(
      [
        type: type
        x: settings.x
        y: settings.y
        maxSpeed: settings.speed
        duration: (delta / settings.speed) * 1000
      ]
    ).one('ChoreographyEnd', ->
      defer.resolve()
    )
    defer.promise

  # Rotate the entity a given set of degrees over an amount of time
  rotate: (degrees, duration) ->
    (sequence) =>
      @_verify(sequence)
      defer = WhenJS.defer()
      cleanup = ->
        defer.resolve()
      @entity.one 'Remove', cleanup
      @entity.tween({ rotation: degrees }, duration)
        .one 'TweenEnd', ->
          @unbind 'Remove', cleanup
          defer.resolve()
      defer.promise

  # Synchronize all enitities within a squad.
  # This promise gets resolved if all entities in a squad
  # have reached this point in their script.
  # Very useful for orchestrated attacks
  synchronizeOn: (name) ->
    (sequence) =>
      # no sequence verification here, or else
      # enemies on an alternate path but still alive
      # will freeze others
      @synchronizer.synchronizeOn(name, this)

  setLocation: (location) ->
    (sequence) =>
      settings = location?() ? location
      @entity.attr(
        x: settings.x - Crafty.viewport.x
        y: settings.y - Crafty.viewport.y
      )

  location: (settings = {}) ->
    =>
      x: (@enemy.location.x ? (@entity.x + Crafty.viewport.x) + (@entity.w / 2))
      y: (@enemy.location.y ? (@entity.y + Crafty.viewport.y) + (@entity.h / 2))

  pickTarget: (selection) ->
    (sequence) =>
      entities = Crafty(selection)
      @target = entities.get Math.floor(Math.random() * entities.length)

  targetLocation: (override = {}) ->
    =>
      x: (override.x ? (@target.x + Crafty.viewport.x)) + (override.offsetX ? 0)
      y: (override.y ? (@target.y + Crafty.viewport.y)) + (override.offsetY ? 0)
