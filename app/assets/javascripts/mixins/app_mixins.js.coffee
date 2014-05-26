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

RssReader.BootstrapAccordion = Ember.Mixin.create(
  isCollapsed: false

  actions:
    collapseToggle: (id) ->
      $("#" + id).find(".collapse").collapse('toggle')

    collapseAll: ->
      $(".collapse").collapse('hide')
      @set('isCollapsed', true)

    expandAll: ->
      $(".collapse").not(".in").collapse('show')
      @set('isCollapsed', false)
)

