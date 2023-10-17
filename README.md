Elovation
===========================

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=elovation_elovation&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=elovation_elovation)

At Braintree, we play ping pong in the office. We wanted a way to track results and assign ratings to players. Elovation was born. It's a simple rails app that tracks the results of any two player game and assigns ratings to the players using the [Elo rating system](http://en.wikipedia.org/wiki/Elo_rating_system).

This also supports individual player rankings within multi-player teams, using the [Trueskill ranking system](http://research.microsoft.com/en-us/projects/trueskill/)

Deploy yourself with Fly.io for free
-------------------------------------
The root of this directory is setup with a Dockerfile ready to deploy to [fly.io](https://fly.io).

To deploy to fly, you must install a command line tool and sign up [using the following instructions](https://fly.io/docs/hands-on/install-flyctl/)

Once you have installed and signed up to fly.io (you can skip the suggested example launcher), you can proceed to generate a fly.toml file for this project to deploy to fly.io

To do this, run `fly launch --dockerfile Dockerfile`, you will be prompted to generate a new project, with a new name. When prompted to setup a postgres database, select yes. You do not need to setup redis, so skip that step.

It should "just work", if it doesn't, please file an issue.

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

Contributing & Development
--------------------------

*Docker*

The root directory of this app contains a `Dockerfile.dev` file, and a `docker-compose.yml` as helpers to make the development experience easier.

Assuming you have Docker installed, you should be able to run `docker compose up` from the root directory, and get your dev instance running and accessible from `http://localhost:4321`

*ASDF*

The root directory contains a .tool-versions file, this is used by a version management tool called [ASDF](https://asdf-vm.com). If you are running Mac OS, you may find you need to run ASDF to help manage your ruby version if you're trying to run without docker, or you wish to make a custom fly.io deployment.

*OS Support*

This was developed in a MacOS environment, but it uses Docker to help with cross-platform compatibility.

When developing/deploying from Windows, please use the Windows Subsystem for Linux, or run the Dockerfiles through a line-endings conversion tool. See: [#115](https://github.com/elovation/elovation/issues/115)
