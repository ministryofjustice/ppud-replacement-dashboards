class Dashing.CircleCi extends Dashing.Widget
  ready: ->
    $(@node).find('ol').remove()

  onData: (data) ->
    @_checkStatus(data.status)

  _checkStatus: (status) ->
    $(@node).removeClass('failed passed running started broken timedout no_tests fixed success canceled')
    $(@node).addClass(status)
