RssReader.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo('feeds')

