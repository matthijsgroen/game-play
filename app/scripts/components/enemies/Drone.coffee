Crafty.c 'Drone',
  init: ->
    @requires '2D, Canvas, Color, Collision, Choreography, Enemy'

  drone: ->
    @attr w: 25, h: 25, health: 100
    @color '#0000FF'

    @onHit 'Bullet', (e) ->
      bullet = e[0].obj
      bullet.trigger 'HitTarget', target: this
      @health -= bullet.damage
      if @health <= 0
        bullet.trigger 'DestroyTarget', target: this
        Crafty.trigger('EnemyDestroyed', this)
        @trigger('Destroyed', this)
        @destroy()
      bullet.destroy()

    this