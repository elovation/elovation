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
    if player.email.blank?
      digest = Digest::MD5.hexdigest(player.name)
      "https://robohash.org/#{digest}?size=#{size}x#{size}"
    else
      digest = Digest::MD5.hexdigest(player.email)
      "https://robohash.org/#{digest}?gravatar=hashed&size=#{size}x#{size}"
    end
  end

  def brand_title
    ENV.fetch("ELOVATION_TITLE", "Elovation")
  end
end
