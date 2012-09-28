Elovation
===========================

[![Travis CI Status](http://travis-ci.org/drewolson/elovation.png)](http://travis-ci.org/drewolson/elovation)

At Braintree, we play ping pong in the office. We wanted a way to track results and assign ratings to players. Elovation was born. It's a simple rails app that tracks the results of any two player game and assigns ratings to the players using the [Elo rating system](http://en.wikipedia.org/wiki/Elo_rating_system).


Deployment
---------------------------

Elovation is optimized for deployment on [Heroku](http://www.heroku.com). Because the app doesn't provide any authentication or authorization, you can turn on basic auth by setting some environment variables in your heroku app.

`heroku config:add BASIC_AUTH=true BASIC_AUTH_USER=username BASIC_AUTH_PASSWORD=password`

After pushing the app to heroku, just run the migrations and you're all set.

`heroku run rake db:migrate`
