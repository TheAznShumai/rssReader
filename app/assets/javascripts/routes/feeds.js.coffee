RssReader.FeedsRoute = Ember.Route.extend
  model: ->
    @get('store').findAll('feed')

RssReader.FeedsShowRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find('feed', params.feed_id)

RssReader.FeedsNewRoute = Ember.Route.extend
  model: ->
    @get('store').createRecord(name: @get('newFeedName'),
                                url: @get('newFeedUrl'))

