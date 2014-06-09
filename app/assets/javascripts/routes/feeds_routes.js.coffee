RssReader.FeedsRoute = Ember.Route.extend(
  model: ->
    @get('store').find('feed')
)

RssReader.FeedsShowRoute = Ember.Route.extend(
  RssReader.TearDownOnTransition
  model: (params) ->
    @get('store').find('feed', params.feed_id)
  deactivate: ->
    @get('controller.poller').stopPoll()
)

RssReader.FeedsNewRoute = Ember.Route.extend(
  RssReader.TearDownOnTransition
  model: ->
    @get('store').createRecord('feed', {name: '', url: 'http://'})
)

