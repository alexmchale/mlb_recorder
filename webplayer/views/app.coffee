$ ->

  $player            = $("#player")
  $source            = $("#source")
  $currentStatus     = $("#currentstatus")
  $playButtons       = $(".playbutton")
  $changeTimeButtons = $(".changetime")

  player             = $player.get(0)

  # Test if the player is playing

  isPlaying = -> !player.paused && !player.ended && 0 < player.currentTime

  updateLabels = ->
    if isPlaying()
      $currentStatus.text("" + player.currentTime + " / " + player.duration)
      $playButtons.text("Pause audio stream")
    else
      $currentStatus.text("Audio stream is paused.")
      $playButtons.text("Play audio stream")

  # Set up buttons that change the time position

  $changeTimeButtons.on "click", (e1) ->
    $button = $(@)
    amount  = parseFloat($button.data("amount"))

    player.currentTime += amount
    e1.preventDefault()

  # Set up the pause/play button

  $playButtons.on "click", (e1) ->
    if isPlaying()
      player.pause()
    else
      player.play()

  # Create an interval to update labels

  setInterval(updateLabels, 100)
