ready = ->
  $('.invalid-clubname').hide()
  $('.valid-clubname').hide()

  $('#club_clubname').on 'keyup', (event) ->
    $.ajax
      url: '/clubname_validator/' + $('#club_clubname').val()
      type: 'GET'
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
      success: (data, textStatus, jqXHR) ->
        if data.valid is true
          $('.invalid-clubname').hide()
          $('.valid-clubname').show()
        else if data.valid is false
          $('.valid-clubname').hide()
          $('.invalid-clubname').show()
    event.stopImmediatePropagation();
    return false
  return false

$(document).ready ready
$(document).on 'turbolinks:load', ready