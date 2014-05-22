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

RssReader.LazyLoader = Ember.Mixin.create(
  storageLocation: ''
  lazyLoadedItems: []
  currentPage: 0
  perPage: 15
  isLoadingMoreItems: false

  canLoadMoreItems: (->
    nextPageInitIndex = @get('currentPage') * @get('perPage')
    return nextPageInitIndex < @get(@get('storageLocation')).length
  ).property('currentPage', 'perPage', 'storageLocation')

  cacheLazyLoadedItems: (->
    return @get('lazyLoadedItems')
  ).property('currentPage', 'perPage', 'storageLocation', 'lazyLoadedItems').cacheable()

  actions:
    initializeLazyLoader: (storageLocation) ->
      @set('lazyLoadedItems', [])
      @set('currentPage', 0)
      @set('isLoadingMoreItems', false)
      @set('storageLocation', storageLocation)

    loadMoreItems: ->
      if @get('canLoadMoreItems')
        @set('isLoadingMoreItems', true)
        nextPageInitIndex = @get('currentPage') * @get('perPage')
        nextPageEndIndex = Math.min((nextPageInitIndex + @get('perPage')), @get(@get('storageLocation')).length)
        @incrementProperty('currentPage')
        Ember.run.later this, (=>
          @lazyLoadedItems.pushObjects(@get(@get('storageLocation')).slice(nextPageInitIndex, nextPageEndIndex))
          @set('isLoadingMoreItems', false)
        ), 500
)

RssReader.BootstrapAccordion = Ember.Mixin.create(
  isCollapsed: false

  actions:
    collapseToggle: (id) ->
      $("#" + id).collapse('toggle')

    collapseAll: ->
      $(".collapse").collapse('hide')
      @set('isCollapsed', true)

    expandAll: ->
      $(".collapse").not(".in").collapse('show')
      @set('isCollapsed', false)
)

