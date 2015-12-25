Crafty.c 'PowerUp',
  init: ->
    @requires '2D,WebGL,Color'
    @color '#20FF20'
    @attr
      w: 20
      h: 20

  remove: ->

  powerUp: (@settings) ->
    if @settings.marking
      marking = Crafty.e('2D,DOM,Text')
        .textColor('#000000')
        .textFont({
          size: '16px',
          weight: 'bold',
          family: 'Bank Gothic'
        })
        .text(@settings.marking)
        .attr x: 4, y: 1
      @attach marking
    this