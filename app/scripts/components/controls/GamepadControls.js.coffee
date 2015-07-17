Crafty.c 'GamepadControls',
  init: ->
    @requires 'Listener'
    @bind 'RemoveComponent', (componentName) ->
      @removeComponent 'GamepadControls' if componentName is 'ControlScheme'

  remove: ->
    @unbind 'GamepadKeyChange', @_keyHandling

  setupControls: (player) ->
    player.addComponent('GamepadControls')
      .controls(@controlMap)
      .addComponent('ControlScheme')

  controls: (controlMap) ->
    @controlMap = controlMap
    return unless controlMap.gamepadIndex?

    @requires 'Gamepad'
    @gamepad controlMap.gamepadIndex

    @bind 'GamepadKeyChange', @_keyHandling
    this

  _keyHandling: (e) ->
    if e.button is @controlMap.fire && e.pressed
      @trigger('Fire', e)

  assignControls: (ship) ->
    ship.addComponent('GamepadMultiway, Gamepad')
      .gamepad(@controlMap.gamepadIndex)
      .gamepadMultiway
        speed: { y: 3, x: 1.5 }
        gamepadIndex: @controlMap.gamepadIndex

    @listenTo ship, 'GamepadKeyChange', (e) =>
      if e.button is @controlMap.fire && e.pressed
        ship.shoot()