'use strict';

Crafty.c('ControlScheme', {
  init: function () {
  }
});

Crafty.c('KeyboardControls', {
  init: function () {
  },
  setupControls: function (player) {
    player.addComponent('KeyboardControls')
      .controls(this.controlMap);
  },
  controls: function (controlMap) {
    this.controlMap = controlMap;
    this.bind('KeyDown', function (e) {
      if (e.key === this.controlMap.fire) {
        this.trigger('Fire', e);
      }
    });
    return this;
  },
  assignControls: function (ship) {
    var controlMap = this.controlMap;

    var movementMap = {};
    movementMap[controlMap.up] = -90;
    movementMap[controlMap.down] = 90;
    movementMap[controlMap.left] = 180;
    movementMap[controlMap.right] = 0;

    ship.addComponent('Multiway, Keyboard')
      .multiway({ y: 3, x: 1 }, movementMap)
      .bind('KeyDown', function (e) {
        if (e.key === controlMap.fire) { this.shoot(); }
      });
  }
});

Crafty.c('GamepadControls', {
  init: function () {
  },
  setupControls: function (player) {
    player.addComponent('GamepadControls')
      .controls(this.controlMap);
  },
  controls: function (controlMap) {
    this.controlMap = controlMap;
    if (controlMap.gamepadIndex === undefined) {
      return;
    }
    this.require('Gamepad');
    this.gamepad(controlMap.gamepadIndex);

    this.bind('GamepadKeyChange', function (e) {
      if (e.button === this.controlMap.fire && e.pressed) {
        this.trigger('Fire', e);
       }
     });
  },
  assignControls: function (ship) {
    var controlMap = this.controlMap;

    var movementMap = {};
    movementMap[controlMap.up] = -90;
    movementMap[controlMap.down] = 90;
    movementMap[controlMap.left] = 180;
    movementMap[controlMap.right] = 0;

    ship.addComponent('Multiway, Keyboard')
      .multiway({ y: 3, x: 1 }, movementMap)
      .bind('KeyDown', function (e) {
        if (e.key === controlMap.fire) { this.shoot(); }
      });
  }
});
