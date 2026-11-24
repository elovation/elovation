# Elovation domain

The language used in code, specs and discussion. When a term here and a name in the code disagree, fix the code or this file.

## Glossary

**Game**: a kind of contest people play, such as table tennis or foosball. It sets the format (how many teams, how many players per team, whether ties are allowed) and the rating system used to rate its players. _Code_: `Game`.

**Player**: a person who plays games. _Code_: `Player`.

**Result**: one played match of a game: two or more teams and the order they finished in. _Code_: `Result`.

**Team**: the players on one side of a result, with that side's rank. A team can have a single player. _Code_: `Team`.

**Rank**: where a team finished in a result. Lower is better, and teams with the same rank tied. The app gives first place rank 1.

**Rating system**: a method for turning results into ratings, such as Elo or TrueSkill. Each rating system is a pure module with the same interface: no database, no knowledge of games or players. A game's rating system can't be changed once it's chosen. _Code_: `RatingSystems::Elo`, `RatingSystems::TrueSkill`; the interface is documented in `app/models/rating_systems.rb`.

**Rating state**: everything a rating system needs to know about one player in one game, such as Elo's rating, games played and pro flag, or TrueSkill's mean and deviation. It is a JSON-compatible Hash that only its rating system interprets. _Code_: `Rating#state` and `RatingHistoryEvent#state` (jsonb). _Avoid_: "rating attributes", "trueskill fields".

**Standing**: the input to a rating system for one team in one result: the team's rank and the rating state of each of its players. _Code_: `RatingSystems::Standing`.

**Rating**: a player's current rating in one game: their rating state plus its score. _Code_: `Rating`.

**Score**: the single integer a rating system derives from a rating state for display and sorting. Elo's score is the rating; TrueSkill's is the conservative estimate (mean - 3 × deviation) × 100. _Code_: `Rating#value`. _Avoid_: calling the score "the rating" when the rating state is meant.

**Rating history**: the sequence of a rating's states, one entry per result the player took part in. _Code_: `RatingHistoryEvent`.
