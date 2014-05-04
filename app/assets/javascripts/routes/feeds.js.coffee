RssReader.FeedsRoute = Ember.Route.extend
  model: ->
    @get('store').find('feed')

RssReader.FeedsShowRoute = Ember.Route.extend
  model: (params) ->
    @get('store').find('feed', params.feed_id)

RssReader.FeedsNewRoute = Ember.Route.extend
  model: ->
    @get('store').createRecord('feed', {name: '', url: 'http://'})

  # TODO - Put teardown code in a place where I can call for general use

  deactivate: ->
    model = @get('controller.model')
    model.rollback()
    model.deleteRecord() if model.get('isNew')

  actions:
    willTransition: (transition) ->
      model = @get('controller.model')
      transition.abort() if model.get('isDirty') and not confirm("You have unsaved changes. They will be lost if you continue!")

