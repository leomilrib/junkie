# junkie

===============

A simple Sinatra APP to check open Pull Requests on your organizations in one place


## Using it
You can use it by [accessing my herokuapp](http://junkie.herokuapp.com/) version. Please keep it in mind it is running on a free Heroku app, so not so _performatic_. Have some patience.

## Getting your own
You can run it on your machine or sever by follwing this steps:

### Running locally
 - `git clone <this repo>`
 - `bundle install`
 - config your `~/.netrc` file to include your GitHub authentication token
 -  `bundle exec ruby app.rb`

### Running on a Heroku app
 - `git clone <this repo>`
 - `bundle install`
 - `git remote add heroku <<Your Heroku app URL>>`
 - `heroku config:set GITHUB_APP_ID=<<Add your GITHUB_APP_ID to Heroku app>>`
 - `heroku config:set GITHUB_APP_SECRET=<<Add your GITHUB_APP_SECRET to Heroku app>>`
 - `heroku config:set SESSION_SECRET=<<Add your SESSION_SECRET to Heroku app>>`
 - `git push heroku master`
 - `heroku open`

## Wanna help?
Hey, fork and pull request me. You are free and I can't stop you :wink:
