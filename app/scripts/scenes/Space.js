'use strict';

Crafty.defineScene('Space', function () {
  // constructor
  Crafty.background('#111');

  var player = Crafty.e('2D, Canvas, Color, Multiway, GamepadMultiway, Keyboard, Gamepad, Collision')
    .attr({ x: 140, y: 350, w: 30, h: 30, lives: 1, points: 0 })
    .color('#F00')
    .multiway({ y: 3, x: 1 }, {
      UP_ARROW: -90,
      DOWN_ARROW: 90,
      LEFT_ARROW: 180,
      RIGHT_ARROW: 0
    })
    .gamepadMultiway({
      speed: { y: 3, x: 1 },
      gamepadIndex: 0
    })
    .bind('Moved', function (from) {
      if (this.hit('Edge')) { // Contain player within playfield
        this.attr({x: from.x, y: from.y});
      }
    })
    .onHit('Enemy', function () {
      this.loseLife();
    })
    .bind('KeyDown', function (e) {
      if (e.key === Crafty.keys.M) { this.shoot(); }
    })
    .bind('GamepadKeyChange', function (e) {
      if (e.button === 0 && e.pressed) { this.shoot(); }
    })
    .bind('BulletHit', function () {
      this.addPoints(10);
    })
    .bind('BulletDestroy', function () {
      this.addPoints(50);
    });

  player.shoot = function () {
    Crafty.e('Bullet')
      .color(this.color())
      .attr({
        x: this.x + this.w,
        y: this.y + (this.h / 2.0),
        w: 5,
        h: 5
      })
      .fire({
        origin: this,
        damage: 100,
        speed: 4,
        direction: 0
      });
  };
  player.loseLife = function () {
    this.lives -= 1;
    this.attr({ x: 140, y: 350 });

    this.trigger('UpdateLives', { lives: this.lives });
    if (this.lives <= 0) {
      Crafty.enterScene('GameOver', { score: this.points });
    }
  };
  player.addPoints = function (amount) {
    this.points += amount;
    this.trigger('UpdatePoints', { points: this.points });
  };

  var score = Crafty.e('2D, Canvas, Text').attr({ x: 10, y: 10, w: 150 }).text('Score: ' + player.points)
    .textColor(player.color())
    .textFont({
      size: '20px',
      weight: 'bold',
      family: 'Courier new'
    });
  player.bind('UpdatePoints', function (e) {
    score.text('Score: ' + e.points);
  });

  Crafty.e('2D, Canvas, Text').attr({ x: 180, y: 10, w: 150 }).text('Lives: ' + player.lives)
    .textColor(player.color())
    .textFont({
      size: '20px',
      weight: 'bold',
      family: 'Courier new'
    });
  player.bind('UpdateLives', function (e) {
    score.text('Lives: ' + e.lives);
  });


  // Create edges around playfield to 'capture' the player
  Crafty.e('2D, Canvas, Edge')
    .attr({x: 10, y: 20, w: 900, h: 2});

  Crafty.e('2D, Canvas, Edge')
    .attr({x: 10, y: 750, w: 900, h: 2});

  Crafty.e('2D, Canvas, Edge')
    .attr({x: 10, y: 20, w: 2, h: 730 });

  Crafty.e('2D, Canvas, Edge')
    .attr({x: 910, y: 20, w: 2, h: 730 });


  var startTime = new Date().getTime();
  var gamespeed = 0.4; // pixels / milisecond
  var nextEnemySpawn = 5000;

  Crafty.bind('EnterFrame', function () {
    var x = ((new Date()).getTime() - startTime) * gamespeed;
    if (nextEnemySpawn < x) {
      var y = Crafty.math.randomInt(40, 720);

      Crafty.e('Enemy').enemy({ x: 1200, y: y });
      nextEnemySpawn += Crafty.math.randomInt(100, 2000);
      console.log('Time to spawn!');
    }
  });

}, function () {
  // destructor
  Crafty.unbind('EnterFrame');
});
