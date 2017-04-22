Elovation
===========================

[![Build Status](https://travis-ci.org/elovation/elovation.png?branch=master)](https://travis-ci.org/elovation/elovation)
[![Code Climate](https://codeclimate.com/github/elovation/elovation/badges/gpa.svg)](https://codeclimate.com/github/elovation/elovation)

At Braintree, we play ping pong in the office. We wanted a way to track results and assign ratings to players. Elovation was born. It's a simple rails app that tracks the results of any two player game and assigns ratings to the players using the [Elo rating system](http://en.wikipedia.org/wiki/Elo_rating_system).

This also supports individual player rankings within multi-player teams, using the [Trueskill ranking system](http://research.microsoft.com/en-us/projects/trueskill/)


Quick Start with Heroku
---------------------------

The fastest way to get started with Elovation is to click the deploy to [Heroku](http://www.heroku.com) button below. Elovation can be run on the free tier, so all you will require is a Heroku account to get started with no running costs.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/elovation/elovation)

If you would like to add a level of authentication security to your app on Heroku, on the setup screen set the "BASIC_AUTH" to "true", and set a username and password in their respective fields. When you try to access your app in future, you will be prompted for your credentials.

The click to deploy button will automatically migrate your database.

Game Options
------------
There are two types of "Games" that Elovation allows for: [Trueskill](https://en.wikipedia.org/wiki/TrueSkill) & [Elo](https://en.wikipedia.org/wiki/Elo_rating_system)

#### Trueskill
Trueskill allows for teams of multiple players, to play other teams - yet still calculate each individual player's ranking.

When creating a new game you may set the maximum numbers of teams in a result, and the maximum number of players per team in a result. You can record a result in any combination up to the maximum.  

The default is set to 2 players per team, and 2 teams per result (like playing a game of doubles Table Tennis / Foosball). The minimum allowed players per team is 1, and the minimum allowed teams per result is 2.

If you increase the allowed number of teams per result, this will allow scenarios where a team can defeat multiple other teams in a single match at the same time. A possible example of this is a Paint Ball / Nerf War with multiple teams that is "last team standing" - All other teams are the losers and the remaining team is the winner.

Suitable for:
- Table Tennis
- Foosball
- Paint Ball / Nerf Wars

#### Elo
Elo is a simpler method devised for Player versus player games only and does not support teams. It also increments and decrements by a set value which makes a win/loss amount more predictable.

Suitable for:
- Chess
- Table Tennis
- Foosball

Caution
-------
If you intend to use this software commercially, you must remove the Trueskill implementation as it is patented by Microsoft.
