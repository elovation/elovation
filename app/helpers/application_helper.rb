module ApplicationHelper
  def gravatar_url(player, options = {})
    options.assert_valid_keys :size
    size = options[:size] || 32
    digest = player.email.blank? ? "0" * 32 : Digest::MD5.hexdigest(player.email)
    "http://www.gravatar.com/avatar/#{digest}?d=mm&s=#{size}"
  end

  def format_time(time)
    time.in_time_zone('Pacific Time (US & Canada)').strftime("%A, %Y %B %d, %l:%M %p")
  end
end
