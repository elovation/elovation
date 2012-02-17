module ApplicationHelper
  def gravatar_url(player, options = {})
    options.assert_valid_keys :size
    size = options[:size] || 32
    if player.gravatar.blank?
      "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&s=#{size}"
    else
      player.gravatar + "?s=#{size}"
    end
  end
end
