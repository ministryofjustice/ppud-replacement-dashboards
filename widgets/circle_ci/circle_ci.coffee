class Dashing.CircleCi extends Dashing.Widget
  ready: ->
    $(@node).find('ol').remove()

  onData: (data) ->
    @_checkStatus(data.workflow_status)

    link = $(@node).find('span.link-hidden').text()
    $(@node).find('a.circle_ci_link').attr('href', link)

  _checkStatus: (status) ->
    $(@node).removeClass('failed passed running started broken timedout no_tests fixed success canceled')
    $(@node).addClass(status)
