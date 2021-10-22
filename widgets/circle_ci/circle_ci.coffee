class Dashing.CircleCi extends Dashing.Widget
  ready: ->

  onData: (data) ->
    $(@node).removeClass('failed passed running started broken timedout no_tests fixed success canceled')
    $(@node).addClass(data.workflow_status)
