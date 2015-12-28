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
