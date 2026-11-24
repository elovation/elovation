# frozen_string_literal: true

module ApplicationHelper
  def errors_for(model, key)
    messages = model.errors.messages_for(key)
    tag.div(messages.join(', '), class: 'field-errors') if messages.any?
  end

  def format_time(time)
    "#{time_ago_in_words(time)} ago"
  end

  # A Robohash avatar. Robohash shows the player's Gravatar when their email
  # has one, and otherwise a robot generated from their email (or name).
  def avatar_url(player, size: 32)
    if player.email.blank?
      digest = Digest::MD5.hexdigest(player.name)
      "https://robohash.org/#{digest}?size=#{size}x#{size}"
    else
      digest = Digest::MD5.hexdigest(player.email)
      "https://robohash.org/#{digest}?gravatar=hashed&size=#{size}x#{size}"
    end
  end

  NAV_SECTIONS = {
    games: %w[dashboard games results ratings],
    players: %w[players player_games]
  }.freeze

  # A main navigation link, marked as the current page while viewing any page
  # in its section.
  def nav_link(name, path, section:)
    current = NAV_SECTIONS.fetch(section).include?(controller_name)
    link_to name, path, aria: { current: current ? 'page' : nil }
  end

  # An avatar shown beside the player's name, so it's decorative (empty alt).
  AVATAR_SIZES = [20, 24, 48, 64].freeze

  def avatar(player, size: 24)
    raise ArgumentError, "avatar size must be one of #{AVATAR_SIZES}" unless AVATAR_SIZES.include?(size)

    image_tag avatar_url(player, size: size * 2), alt: '', width: size, height: size, class: "avatar avatar-#{size}"
  end

  # The theme for this page: the game's when there is one, otherwise the
  # site's.
  def current_theme
    @game ? @game.look : Theme.site
  end

  def brand_title
    ENV.fetch('ELOVATION_TITLE', 'Elovation')
  end
end
