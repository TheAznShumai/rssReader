RssReader.IndexRoute = Ember.Route.extend(
  redirect: ->
    @transitionTo('feeds')
)

RssReader.TearDownOnTransition = Ember.Mixin.create(
  actions:
    willTransition: (transition) ->
      model = @get('controller.model')
      if model.get('isDirty') and not model.get('isDeleted') and
      not confirm("You have unsaved changes. They will be lost if you continue!")
        transition.abort()
      else
        model.rollback()
        model.deleteRecord() if model.get('isNew')
        @get('controller').set('isEditing', false) if model.get('isLoaded')
)

