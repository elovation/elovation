# frozen_string_literal: true

module GamesHelper
  CHART_HIGHLIGHTS = 6

  # Chartkick series for a rating-history chart. The players in `highlighted`
  # (at most six, in leaderboard order) get the theme's chart colours and a
  # thicker line; everyone else is a thin muted line drawn behind them. The
  # colours are theme tokens, which chart_theme_controller.js resolves, and
  # the leaderboard shows the same colour beside each highlighted player.
  def rating_chart_series(history, highlighted)
    history.map do |player, scores|
      index = highlighted.first(CHART_HIGHLIGHTS).index(player.id)
      {
        name: player.name,
        data: scores,
        token: index ? "--chart-#{index + 1}" : '--chart-muted',
        dataset: index ? { borderWidth: 2.5, order: 1 } : { borderWidth: 1, order: 10 }
      }
    end
  end

  def rating_chart(series, height:)
    tag.div(class: 'chart-canvas', data: { controller: 'chart-theme' }) do
      line_chart series, height: height, min: nil, max: nil, curve: false, points: false, legend: false,
                         xtitle: 'Date', ytitle: @game.rating_system.name
    end
  end
end
