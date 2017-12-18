PresentationLeaveScreen = require('./lunch/presentation_leave_screen').default
{ LazerScript } = require('src/lib/LazerScript')

class Stage1End extends LazerScript

  assets: ->
    @loadAssets('explosion')

  execute: ->
    @sequence(
      @parallel(
        @sequence(
          @disableControls()
          @disableWeapons()
          @placeSquad(PresentationLeaveScreen,
            amount: 2
            delay: 1000
          )
        )
        @sequence(
          @say 'This is it for now!\nMore content coming soon!'
          @say 'Thanks for playing!\nThe heroes will return...'
        )
      )
      @screenFadeOut()
      @endGame()
    )

module.exports =
  default: Stage1End
