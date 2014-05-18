RssReader.FeedsRoute = Ember.Route.extend(
  model: ->
    @get('store').find('feed')
)

RssReader.FeedsShowRoute = Ember.Route.extend(
  model: (params) ->
    @get('store').find('feed', params.feed_id)
  RssReader.TearDownOnTransition
)

RssReader.FeedsNewRoute = Ember.Route.extend(
  model: ->
    @get('store').createRecord('feed', {name: '', url: 'http://'})
  RssReader.TearDownOnTransition
)

