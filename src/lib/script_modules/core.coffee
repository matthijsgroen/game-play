# Core scripting mechanics. Mainly Controlflow statements
#
#  - sequence
#  - parallel
#  - if
#  - while
#  - repeat
#  - runScript
#  - async
#  - wait
#  - checkpoint
#
Core =
  _verify: (sequence) ->
    throw new Error('sequence mismatch') unless sequence is @currentSequence
    @level.verify()

  _skippingToCheckpoint: ->
    @startAtCheckpoint? and @currentCheckpoint < @startAtCheckpoint

  # Runs a sequence of steps.
  # example:
  #
  #   @sequence(
  #     @moveTo(x: 30)
  #     @moveTo(y: 50)
  #   )
  sequence: (tasks...) ->
    (sequence) =>
      @_verify(sequence)
      WhenJS.sequence(tasks, sequence)

  # Runs steps in parallel, and completes when the last branch has finished.
  # example:
  #
  #   @parallel(
  #     @placeSquad EnemyType1
  #     @placeSquad EnemyType2
  #   )
  parallel: (tasks...) ->
    (sequence) =>
      @_verify(sequence)
      WhenJS.parallel(tasks, sequence)

  # Executes step conditionally.
  # example:
  #
  #   @if((=> Math.random() > 0.5),
  #     @sequence(...)
  #   # else
  #     @sequence(...)
  #   )
  if: (condition, block, elseBlock) ->
    (sequence) =>
      @_verify(sequence)
      if condition.apply this
        block(sequence)
      else
        elseBlock?(sequence)

  # Repeat until condition is met.
  # example:
  #
  #   @while((=> Math.random() > 0.5),
  #     @sequence(...)
  #   )
  #
  # if no condition is provided, it will
  # loop forever. (see `repeat`)
  while: (condition, block) ->
    (sequence) =>
      @_verify(sequence)
      return WhenJS() if @_skippingToCheckpoint()
      if block is undefined
        block = condition
        condition = ->
          # Never resolving promise
          d = WhenJS.defer()
          d.promise

      whileResolved = no
      condition(sequence)
        .then ->
          console.log('resolved')
          whileResolved = yes
        .catch (e) ->
          console.log('rejected')
          whileResolved = yes
          throw e unless e.message is 'sequence mismatch'
        .finally -> whileResolved = yes
      WhenJS.iterate(
        -> 1
        -> whileResolved
        -> !whileResolved && block(sequence)
        1
      )

  # Repeat forever or amount of times.
  # example for infinite repeat (see `while`):
  #
  #   @repeat @placeSquad EnemyType1
  #
  # example:
  #
  #   @repeat 3, @placeSquad EnemyType1
  repeat: (times, block) ->
    (sequence) =>
      @_verify(sequence)
      return WhenJS() if @_skippingToCheckpoint()
      # Syntactic sugar:
      # this allows for writing
      # @repeat(@sequence( ...
      #
      # which feels more natural
      # that a @while without a condition
      if block is undefined
        return @while(times)(sequence)

      return if times is 0
      WhenJS(block(sequence)).then =>
        @repeat(times - 1, block)(sequence)

  choose: (sequences...) ->
    (sequence) =>
      @_verify(sequence)
      pick = Math.floor(Math.random() * sequences.length)
      sequences[pick](sequence)

  chance: (perc, sequences...) ->
    (sequence) =>
      @_verify(sequence)
      if Math.random() < perc
        sequences[0](sequence)
      else
        pick = Math.floor(Math.random() * (sequences.length - 1))
        sequences[1 + pick](sequence)

  # Run a subscript, and continue after completion.
  # example:
  #
  #   @runScript EnemyType1, argsForScript...
  runScript: (scriptClass, args...) ->
    (sequence) =>
      @_verify(sequence)
      return WhenJS() if @_skippingToCheckpoint()
      new scriptClass(@level).run(args...)

  # Execute a task, but don't wait for results.
  async: (task) ->
    (sequence) =>
      @_verify(sequence)
      return WhenJS() if @_skippingToCheckpoint()
      task(sequence).catch((e) ->
        throw e unless e.message is 'sequence mismatch'
      )
      return

  lazy: (func, args...) ->
    (sequence) =>
      return func.apply(this, args)(sequence)

  # Wait an amount of milliseconds.
  wait: (amount) ->
    (sequence) =>
      @_verify(sequence)
      return Promise.resolve() if @_skippingToCheckpoint()
      level = this
      duration = Math.max(amount?() ? amount, 0)
      parts = duration // 40
      new Promise((resolve, reject) ->
        Crafty.e('Delay').delay(
          ->
            try
              level._verify(sequence)
            catch e
              reject(e)
              @destroy()
            null
          40
          parts
          ->
            resolve()
            @destroy()
        )
      )

  # Stops the current script chain.
  endSequence: ->
    (sequence) =>
      @_verify(sequence)
      throw new Error('sequence mismatch')

  # Define a checkpoint.
  # When the user starts at this checkpoint,
  # the provided task is executed.
  #
  # Typically, this task sets the correct background,
  # provides a small delay to ease the player in the gameplay
  # and could provide some powerups.
  checkpoint: (task) ->
    (sequence) =>
      @_verify(sequence)
      @currentCheckpoint += 1
      return WhenJS() if @_skippingToCheckpoint()
      if @currentCheckpoint is @startAtCheckpoint and task?
        task(sequence)
      else
        window.ga('send', 'event', 'Game', "Checkpoint #{@currentCheckpoint}")

module.exports =
  default: Core
