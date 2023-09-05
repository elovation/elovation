module ApplicationHelper
  def errors_for(model, key)
    tag.div do
      model.errors.messages_for(key).join(", ")
    end
  end

  def format_time(time)
    "#{time_ago_in_words(time)} ago"
  end

  def gravatar_url(player, options = {})
    options.assert_valid_keys :size
    size = options[:size] || 32
    digest = player.email.blank? ? "0" * 32 : Digest::MD5.hexdigest(player.email)
    "http://www.gravatar.com/avatar/#{digest}?d=mm&s=#{size}"
  end

  def brand_title
    ENV.fetch("ELOVATION_TITLE", "Elovation")
  end
end
