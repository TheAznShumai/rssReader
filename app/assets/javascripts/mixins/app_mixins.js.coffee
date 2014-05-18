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
  lazyLoadedItems: []
  currentPage: 0
  perPage: 25
  isLoadingMoreItems: false
  storageLocation: ''

  canLoadMoreItems: ->
    nextPageInitIndex = @get('currentPage') * @get('perPage')
    return nextPageInitIndex < @get(@get('storageLocation')).length

  actions:
    initializeLazyLoader: (storageLocation) ->
      @set('lazyLoadedItems', [])
      @set('currentPage', 0)
      @set('isLoadingMoreItems', false)
      @set('storageLocation', storageLocation)

    loadMoreItems: ->
      if @get('canLoadMoreItems')
        self = this
        @set('isLoadingMoreItems', true)
        nextPageInitIndex = @get('currentPage') * @get('perPage')
        nextPageEndIndex = Math.min((nextPageInitIndex + @get('perPage')), @get(@get('storageLocation')).length)
        @incrementProperty('currentPage')
        Ember.run.later this, (->
          self.lazyLoadedItems.pushObjects(self.get(self.get('storageLocation')).slice(nextPageInitIndex, nextPageEndIndex))
          self.set('isLoadingMoreItems', false)
        ), 100
)

