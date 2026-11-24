# Replaces per-rating-system columns (pro, trueskill_mean, trueskill_deviation)
# with one opaque `state` that only the game's rating system interprets.
class StoreRatingState < ActiveRecord::Migration[8.1]
  def up
    add_column :ratings, :state, :jsonb
    add_column :rating_history_events, :state, :jsonb

    # Current ratings. Elo's games played is the number of results rated so far.
    execute <<~SQL
      UPDATE ratings SET state = jsonb_build_object(
        'rating', ratings.value,
        'games_played', (SELECT count(*) FROM rating_history_events e WHERE e.rating_id = ratings.id),
        'pro', ratings.pro
      )
      FROM games WHERE games.id = ratings.game_id AND games.rating_type = 'elo';

      UPDATE ratings SET state = jsonb_build_object(
        'mean', ratings.trueskill_mean,
        'deviation', ratings.trueskill_deviation
      )
      FROM games WHERE games.id = ratings.game_id AND games.rating_type = 'trueskill';
    SQL

    # History. Elo history never stored games played or the pro flag, so they
    # are reconstructed: games played is the event's position in the rating's
    # history, and a player is a pro from the first time they reached 2400.
    execute <<~SQL
      UPDATE rating_history_events SET state = jsonb_build_object(
        'rating', reconstructed.value,
        'games_played', reconstructed.games_played,
        'pro', reconstructed.pro
      )
      FROM (
        SELECT e.id, e.value,
          row_number() OVER history AS games_played,
          bool_or(e.value >= 2400) OVER history AS pro
        FROM rating_history_events e
        JOIN ratings r ON r.id = e.rating_id
        JOIN games g ON g.id = r.game_id AND g.rating_type = 'elo'
        WINDOW history AS (PARTITION BY e.rating_id ORDER BY e.created_at, e.id ROWS UNBOUNDED PRECEDING)
      ) reconstructed
      WHERE reconstructed.id = rating_history_events.id;

      UPDATE rating_history_events SET state = jsonb_build_object(
        'mean', rating_history_events.trueskill_mean,
        'deviation', rating_history_events.trueskill_deviation
      )
      FROM ratings r JOIN games g ON g.id = r.game_id AND g.rating_type = 'trueskill'
      WHERE r.id = rating_history_events.rating_id;
    SQL

    change_column_null :ratings, :state, false
    change_column_null :rating_history_events, :state, false

    remove_column :ratings, :pro
    remove_column :ratings, :trueskill_mean
    remove_column :ratings, :trueskill_deviation
    remove_column :rating_history_events, :trueskill_mean
    remove_column :rating_history_events, :trueskill_deviation
  end

  def down
    add_column :ratings, :pro, :boolean
    add_column :ratings, :trueskill_mean, :float
    add_column :ratings, :trueskill_deviation, :float
    add_column :rating_history_events, :trueskill_mean, :float
    add_column :rating_history_events, :trueskill_deviation, :float

    execute <<~SQL
      UPDATE ratings SET
        pro = coalesce((state->>'pro')::boolean, false),
        trueskill_mean = (state->>'mean')::float,
        trueskill_deviation = (state->>'deviation')::float;

      UPDATE rating_history_events SET
        trueskill_mean = (state->>'mean')::float,
        trueskill_deviation = (state->>'deviation')::float;
    SQL

    change_column_null :ratings, :pro, false

    remove_column :ratings, :state
    remove_column :rating_history_events, :state
  end
end
