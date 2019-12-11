defaults = require('lodash/defaults')
isFunction = require('lodash/isFunction')
isObject = require('lodash/isObject')
extend = require('lodash/extend')
clone = require('lodash/clone')
{ lookup } = require('src/lib/random')
{ normalizeInputPath, getBezierPath } = require('src/lib/BezierPath')
createEntityPool = require('src/lib/entityPool').default

shadowPool = createEntityPool(
  ->
    Crafty.e('2D, WebGL, shadow, Choreography, Tween')
  10
)

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
#
Entity =
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
    @_boundSequences ||= []
    return unless sequenceFunction?
    filter ?= -> true
    eventHandler = (args...) =>
      return unless filter(args...)
      @entity.unbind(eventName, eventHandler)
      p = (sequence) =>
        @alternatePath = null
        WhenJS(sequenceFunction.apply(this, args)(sequence)).catch =>
          @alternatePath

      @currentSequence = sequence = lookup()
      @alternatePath = p(sequence)

    @entity.bind(eventName, eventHandler)
    @_boundEntity = @entity
    @_boundSequences.push([eventName, eventHandler])

  _unbindSequences: ->
    @_boundSequences ||= []
    while (info = @_boundSequences.shift())
      @_boundEntity.unbind(info[0], info[1])

  # remove an entity from the current gameplay. This means it cannot shoot
  # the player, and the player cannot shoot the entity. This is useful
  # for moving entities behind scenery.
  sendToBackground: (scale, z = null) ->
    (sequence) =>
      @_verify(sequence)
      if z is null
        z = @entity.z
      @entity.sendToBackground(scale, z)

  reveal: ->
    (sequence) =>
      @_verify(sequence)
      @entity.reveal()

  animate: (reel, repeat, member) ->
    (sequence) =>
      @_verify(sequence)
      if member
        @entity[member].animate(reel, repeat)
      else
        @entity.animate(reel, repeat)

  scale: (scale, options = {}) ->
    (sequence) =>
      @_verify(sequence)
      oscale = @entity.scale ? 1.0
      options = defaults(options,
        duration: Math.abs(scale - oscale) * 1000
      )
      d = WhenJS.defer()

      cleanup = ->
        defer.resolve()

      @entity.tween({
        scale: scale
      }, options.duration).one 'TweenEnd', ->
        @unbind 'Remove', cleanup
        d.resolve()
      d.promise

  # Move an entity through a set of coordinates (relative to the viewport)
  # in a bezier path. By default the entity moves with its own 'defaultSpeed'
  # property, but it can be overridden with settings.
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
  # - speed: override the defaultSpeed of the entity (in px/sec)
  # - rotate: yes/no should the entity rotate along the path?
  # - skip: amount of milliseconds to skip in this animation
  # - easing: one of the following:
  #   - "linear" (default)
  #   - "smoothStep"
  #   - "smootherStep"
  #   - "easeInQuad"
  #   - "easeOutQuad"
  #   - "easeInOutQuad".
  # - continuePath: should this path continue the previous one
  movePath: (inputPath, settings = {}) ->
    (sequence) =>
      @_verify(sequence)
      if not @enemy.alive and not @decoyingEntity?
        return Promise.resolve()

      settings = defaults(settings,
        rotate: yes
        skip: 0
        speed: @entity.defaultSpeed
        continuePath: no
        easing: 'linear'
        autoAccellerate: yes
        debug: no
      )

      path = [].concat inputPath
      path.unshift [
        @entity.x
        @entity.y
      ]

      normalized = normalizeInputPath(path)
      bp = getBezierPath(normalized)

      debugPoints = []
      if settings.debug
        debugPoints = debugPoints.concat normalized.map((point, i) ->
          Crafty.e("2D, DOM, Color, MovePathDebug")
            .attr({
              x: point.x,
              y: point.y,
              w: 5,
              h: 5,
              z: -50
            }).color("#FFFFFF")
        )
        debugPoints = debugPoints.concat normalized.map((point, i) ->
          Crafty.e("2D, DOM, Text, MovePathDebug")
            .attr({
              x: point.x + 8,
              y: point.y,
              w: 50,
              h: 20,
              z: -50
            }).text(i)
        )
        debugPoints = debugPoints.concat bp.getLUT(50).map((point) ->
          Crafty.e("2D, DOM, Color, MovePathDebug")
            .attr({
              x: point.x,
              y: point.y,
              w: 3,
              h: 3,
              z: -50
            }).color("#00FF00")
        )

      new Promise((resolve) =>
        @entity.addComponent("BezierMove")
        @entity.one('BezierMoveEnd', resolve)
        @entity.bezierMove(bp, settings)
      ).then ->
        debugPoints.forEach((p) -> p.destroy())

  _isFloat: (n) ->
    n is +n and n isnt (n|0)

  # Moves the entity to a coordinate
  # the provided coordinate can also be a function (that does not take arguments)
  # that returns an object with an 'x' and an 'y'.
  #
  # This method moves an entity below water if the Y gets below the 'seaLevel'
  #
  # extra settings can be provided:
  # - speed: override the default speed of the entity (in px/sec)
  # - easing: one of the following:
  #   - "linear" (default)
  #   - "smoothStep"
  #   - "smootherStep"
  #   - "easeInQuad"
  #   - "easeOutQuad"
  #   - "easeInOutQuad".
  moveTo: (location, extraSettings = {}) ->
    (sequence) =>
      @_verify(sequence)
      if not @enemy.alive and not @decoyingEntity?
        return Promise.resolve()

      if typeof location is 'string'
        target = Crafty(location).get 0
        offsets = defaults(extraSettings,
          offsetX: 0
          offsetY: 0
        )
        location = {
          x: target.x + offsets.offsetX
          y: target.y + offsets.offsetY
        }

      settings = location?() ? location

      # When the location function returns null,
      # settings becomes the function, which is
      # invalid. So we need to safeguard against it.
      return Promise.resolve() if isFunction settings

      extend(settings, extraSettings)

      if settings.x? and (-2 < settings.x < 2)
        settings.x *= Crafty.viewport.width

      if settings.y? and (-2 < settings.y < 2)
        settings.y *= Crafty.viewport.height

      if settings.dy?
        settings.y = (settings.y || @entity.y) + settings.dy

      if settings.dx?
        settings.x = (settings.x || @entity.x) + settings.dx

      #if settings.positionType is 'absoluteY'
        #settings.y += Crafty.viewport.y

      throw new Error('location invalid') unless isObject(location)

      seaLevel = @_getSeaLevel()

      if @enemy.moveState is 'air'
        # transition from air to underwater? break movement in 2 parts
        if settings.y? and settings.y + @entity.h > seaLevel
          airSettings = clone settings
          airSettings.y = Math.max(seaLevel - @entity.h, @entity.y)
          return @_moveAir(airSettings)
            .then =>
              @enemy.moveState = 'water'
              return if not @enemy.alive and not @decoyingEntity?
              @_setupWaterSpot()
              @_moveWater(settings)
        else
          return @_moveAir(settings)

      if @enemy.moveState is 'water'
        # transition from underwater to air? break movement in 2 parts
        if settings.y? and settings.y + @entity.h < seaLevel
          waterSettings = clone settings
          waterSettings.y = seaLevel - @entity.h
          return @_moveWater(waterSettings)
            .then =>
              @enemy.moveState = 'air'
              return if not @enemy.alive and not @decoyingEntity?
              @_removeWaterSpot()
              @_moveAir(settings)
        else
          return @_moveWater(settings)

  moveThrough: (location, options) ->
    (sequence) =>
      @_verify(sequence)

      x = @entity.x
      y = @entity.y

      if res = location?()
        tx = res.x
        ty = res.y
      else
        [tx, ty] = location

      if tx? and ty?
        dx = tx - x
        dy = ty - y
      else
        dx = -1
        dy = 0

      rad = Math.atan2(dy, dx)
      fx = (Math.cos(rad) * 1000) + x
      fy = (Math.sin(rad) * 1000) + y
      opts = defaults(
        {
          x: fx,
          y: fy
        }
        options,
        { rotation: yes },
      )
      @moveTo(opts)(sequence)

  _setupWaterSpot: ->
    waterSpot = shadowPool.get()
      .attr(
        w: @entity.w + 10
        x: @entity.x - 5
        y: @_getSeaLevel() - 10
        h: 20
        z: @entity.z - 1
      )

    @entity.addComponent('WaterSplashes')

    @entity.hide(waterSpot, below: @_getSeaLevel())

  _removeWaterSpot: ->
    @entity.reveal()
    if Game.explosionMode?
      @_waterSplash()
    else
      @entity.removeComponent('WaterSplashes')

  _moveWater: (settings) ->
    defaultValues =
      speed: @entity.defaultSpeed

    seaLevel = @_getSeaLevel()
    settings = defaults(settings, defaultValues)
    surfaceSize =
      w: @entity.w * 1.2
      h: (@entity.w / 3)
      alpha: 0.6
    maxSupportedDepth = 700
    maxDepthSize =
      w: @entity.w * .3
      h: 5
      alpha: 0.2

    deltaX = if settings.x? then Math.abs(settings.x - @entity.hideMarker.x) else 0
    deltaY = if settings.y? then Math.abs(settings.y - @entity.hideMarker.y) else 0
    delta = Math.sqrt((deltaX ** 2) + (deltaY ** 2))
    duration = (delta / settings.speed) * 1000

    if settings.y?
      depth = Math.max(0, Math.min(settings.y - @entity.h, maxSupportedDepth) - seaLevel)
      v = depth / (maxSupportedDepth - seaLevel)

      depthProperties = {}

      for k, p of surfaceSize
        depthProperties[k] = (1 - v) * p + (v * maxDepthSize[k])

      @entity.hideMarker.tween depthProperties, duration

    defer = WhenJS.defer()

    newH = depthProperties?.h ? @entity.hideMarker.h
    @entity.hideMarker.choreography([
      type: 'viewport'
      x: (settings.x + (@entity.w / 2)) - (@entity.hideMarker.w / 2)
      y: seaLevel - (newH / 2)
      maxSpeed: settings.speed
      duration: duration
    ]).one('ChoreographyEnd', ->
      defer.resolve()
    )
    WhenJS.all([defer.promise, @_moveAir(settings)])

  _getSeaLevel: ->
    Crafty.s('SeaLevel').getSeaLevel(@entity.scale)

  _moveAir: (settings) ->
    defaultsValues =
      speed: @entity.defaultSpeed

    settings = defaults(settings, defaultsValues)

    deltaX = if settings.x? then Math.abs(settings.x - @entity.x) else 0
    deltaY = if settings.y? then Math.abs(settings.y - @entity.y) else 0
    delta = Math.sqrt(((deltaX || 0) ** 2) + ((deltaY || 0) ** 2))
    return Promise.resolve() if delta == 0

    return new Promise((resolve) =>
      easing = settings.easing ? 'linear'
      @entity.choreography(
        [
          type: 'viewport'
          x: settings.x
          y: settings.y
          rotation: settings.rotation
          easingFn: easing
          maxSpeed: settings.speed
          duration: (delta / settings.speed) * 1000
        ]
      ).one('ChoreographyEnd', ->
        resolve()
      )
    )

  detach: ->
    (sequence) =>
      @_verify(sequence)
      if @entity._parent
        @entity._parent.detach(@entity)


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

  squadOnce: (name, events) ->
    (sequence) =>
      @_verify(sequence)
      if @synchronizer.allowOnce(name)
        events(sequence)

  setLocation: (location) ->
    (sequence) =>
      settings = location?() ? location
      { x, y } = settings

      if @_isFloat(x) or -1 < x < 2
        x *= Crafty.viewport.width

      if @_isFloat(y) or -1 < y < 2
        y *= Crafty.viewport.height

      @entity.attr(
        x: x
        y: y
      )

  location: (settings = {}) ->
    =>
      if @decoyingEntity?
        x: @entity.x + (@entity.w / 2) + (settings.offsetX ? 0)
        y: @entity.y + (@entity.h / 2) + (settings.offsetY ? 0)
      else
        x: (@enemy.location.x ? @entity.x + (@entity.w / 2)) + (settings.offsetX ? 0)
        y: (@enemy.location.y ? @entity.y + (@entity.h / 2)) + (settings.offsetY ? 0)

  get: (property) ->
    =>
      @entity.getProperty(property)

  invincible: (yesNo) ->
    (sequence) =>
      @_verify(sequence)
      @entity.invincible = yesNo

  turnAround: ->
    (sequence) =>
      @_verify(sequence)
      @turned ?= @entity.xFlipped ? no
      @turned = !@turned
      if @turned
        @entity.flipX()
      else
        @entity.unflipX()

  deathDecoy: ->
    (sequence) =>
      @_verify(sequence)
      decoyOpts = Object.assign({}, @options, { decoy: true })
      @decoy = @spawnDecoy(decoyOpts)
      if @options.attach
        attachIndex = (@options.attachOffset || 0) + @options.index
        attachPoint = Crafty(@options.attach).get(attachIndex)
        attachPoint.attach(@decoy)
        @decoy.attr({
          x: attachPoint.x + (@options.attachDx || 0)
          y: attachPoint.y + (@options.attachDy || 0)
          z: attachPoint.z
          invincible: yes
          deathDecoy: yes
          health: 1
          defaultSpeed: @entity.defaultSpeed
        })
      else
        { x, y } = @location()()
        @decoy.attr(
          x: x
          y: y
          invincible: yes
          deathDecoy: yes
          health: 1 # TODO: looks should be determined by 'deathDecoy' flag.
          defaultSpeed: @entity.defaultSpeed
        )

      # TODO: Fix this in the spawn logic
      @decoy.removeComponent('BurstShot') if @decoy.has('BurstShot')
      @decoy.removeComponent('Hostile') if @decoy.has('Hostile')

      @decoy.updatedHealth()
      if @entity.xFlipped
        @decoy.flipX()
      else
        @decoy.unflipX()
      @decoyingEntity = @entity
      @entity = @decoy

  endDecoy: ->
    (sequence) =>
      if @decoy
        @cleanupDecoy @decoy
      @decoy = null
      @entity = @decoyingEntity
      @decoyingEntity = undefined

  leaveAnimation: (task) ->
    (sequence) =>
      @_verify(sequence)
      return WhenJS() if @_skippingToCheckpoint()
      @entity.addComponent('KeepAlive')
      task(sequence).then =>
        if @enemy.alive
          @cleanup(entity)
      return

  action: (name, args) ->
    (sequence) =>
      @_verify(sequence)
      return WhenJS() if @_skippingToCheckpoint()
      WhenJS(@entity.execute(name, args, this))

module.exports =
  default: Entity