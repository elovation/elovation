toggleFields = () ->
  $('#game_rating_type').change ->
    if $(this).find('option:selected').attr('value') == 'elo'
      $('#max_players_control_group').hide()
      $('#max_teams_control_group').hide()
      $('#game_max_number_of_players_per_team')[0].value = 1
    else
      $('#max_players_control_group').show()
      $('#max_teams_control_group').show()
      $('#game_max_number_of_players_per_team')[0].value = 2

$ ->
  toggleFields() if $('#new_game').length != 0
