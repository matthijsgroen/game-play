Crafty.c 'Enemy',
  init: ->
    @requires '2D, Canvas, Color, Collision'

  enemy: ->
    @attr w: 50, h: 50, health: 300
    @color '#0000FF'
    @bind 'EnterFrame', ->
      @x = @x - 1
      minX = (-Crafty.viewport._x)
      @destroy() if @x < minX

    @onHit 'Bullet', (e) ->
      bullet = e[0].obj
      bullet.trigger 'HitTarget', target: this
      @health -= bullet.damage
      if @health <= 0
        bullet.trigger 'DestroyTarget', target: this
        @destroy()
      bullet.destroy()

    this