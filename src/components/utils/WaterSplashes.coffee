Crafty.c 'WaterSplashes',
  init: ->
    @bind 'GameLoop', @_waterSplashes
    @cooldown = 0
    @defaultWaterCooldown ?= 70
    @waterRadius ?= 5
    @minSplashDuration ?= 210
    @detectionOffset = 0
    @minOffset = -10
    @waterAlpha ?= .6
    @splashUpwards = false

  remove: ->
    @unbind 'GameLoop', @_waterSplashes

  setSealevel: (@sealevel) ->
    this

  setDetectionOffset: (@detectionOffset, @minOffset = -10) ->
    this

  _waterSplashes: (fd) ->
    return if Game.explosionMode?
    @cooldown -= fd.dt
    if (@y + @h + @detectionOffset > @sealevel) and (@y < @sealevel) and (@cooldown <= 0)
      speed = @waterSplashSpeed ? @defaultSpeed
      @cooldown = @defaultWaterCooldown
      upwards = 1
      if @_lastWaterY isnt @y and @splashUpwards
        upwards = (speed - 20) / 30

      upwards *= @scale ? 1

      coverage = 45
      parts = (@w / coverage)
      r = 0
      for i in [0...parts]
        for d in [0...Math.min(upwards, 3)]
          r += 1
          pos = Math.random()
          sealevel = @sealevel
          Crafty.e('Blast, ViewportRelativeMotion')
            .colorOverride('#FFFFFF')
            .viewportRelativeMotion(
              x: @x + (i * coverage) + (pos * coverage)
              y: @sealevel + @minOffset
              speed: 1
            )
            .explode(
              upwards: if r % 2 is 0 then upwards else 0
              x: @x + (i * coverage) + (pos * coverage)
              y: @sealevel + @minOffset
              z: @z + 3
              duration: @minSplashDuration + (Math.random() * 100)
              radius: @waterRadius
              topDesaturation: @topDesaturation
              bottomDesaturation: @bottomDesaturation
              alpha: @waterAlpha
              gravity: 0.2
              (prev) ->
                @attr(
                  gravity: @gravity + 0.3
                  alpha: Math.max(0.1, (@alpha - Math.random() * .03))
                )
                return {
                  y: Math.min(prev.y - (Math.random() * @upwards) + @gravity, sealevel - 10)
                  x: prev.x + ((-.5 + pos) * Math.random() * 4.0)
                  w: prev.w + .3
                  h: prev.h + .3
                }
            )
    @_lastWaterY = @y
