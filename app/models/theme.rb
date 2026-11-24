# frozen_string_literal: true

# The look of the app's pages. Each game can have its own theme; every other
# page (and a game without one) uses the site's theme, which whoever runs the
# app sets with ELOVATION_THEME. Themes only change colours, heading type and
# decoration (see app/assets/stylesheets/themes.css), so every theme is
# equally legible.
module Theme
  NAMES = {
    'generic' => 'Generic',
    'chess' => 'Chess',
    'foosball' => 'Foosball',
    'table-tennis' => 'Table tennis'
  }.freeze

  def self.keys = NAMES.keys

  def self.options = NAMES.map { |key, name| [name, key] }

  def self.site = ENV['ELOVATION_THEME'].presence_in(keys) || 'generic'
end
