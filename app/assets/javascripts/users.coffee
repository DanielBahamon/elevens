$(document).on "ajax:success", "._follow, ._unfollow", (event, data, status, xhr) ->
  $(event.target).closest(".user-actions").html(data)

$(document).on "ajax:error", "._follow, ._unfollow", (event, xhr, status, error) ->
  console.log "Error: #{error}"
