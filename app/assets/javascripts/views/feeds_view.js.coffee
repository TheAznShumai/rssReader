RssReader.FeedCollectionView = Ember.CollectionView.extend(
  init: ->
    Ember.run.later this, (=>
      @get('controller').send('loadRssFeed')
      @pushObject(RssReader.FeedView.create(id: @get('controller.content.id')))
    ), 100

  idDidChange: (->
    viewIndex = @get('viewIndex')
    @send('hideAllChildren')
    if Ember.isBlank(viewIndex)
      Ember.run.later this, (=>
        @pushObject(RssReader.FeedView.create(id: @get('controller.content.id'), lazyLoadedItems: []))
      ), 100
    else
      @send('showChildWithId', @get('controller.id'))
    Ember.run.next this, ->
      @get('controller').send('loadRssFeed')
  ).observes('controller.id')

  viewIndex: (->
    viewIndex = null
    @get('childViews').forEach (view, index) =>
      viewIndex = index if view.id == @get('controller.id')
    return viewIndex
  ).property().volatile()

  # TODO - Optimize the process more and fix viewIndex

  feedDataDidChange: (->
    feedData = @get('controller.feedData')
    if not Ember.isBlank(feedData)
      childView = @get('childViews')[@get('viewIndex')]
      if not Ember.isBlank(childView)
        childView.set('feedData', feedData)
      else
        if childView.feedData[0] != feedData[0]
          debugger
          #do some appending if needed
  ).observes('controller.feedData')

  actions:
    showChildWithId: (id) ->
      @get('childViews').forEach (view, index) ->
        view.set('isVisible', true) if view.id == id and not view.isVisible
    hideAllChildren: ->
      @get('childViews').forEach (view, index) ->
        view.set('isVisible', false) if view.isVisible
)

RssReader.FeedView = Ember.View.extend(
  layoutName: 'feed-show-layout'
  templateName: 'feed-data-template'

  id: -1
  feedData: []
  lazyLoadedItems: []
  currentPage: 0
  perPage: 15
  isLoadingMoreItems: false

  isFeedEmpty: (->
    return Ember.isBlank(@get('feedData'))
  ).property('feedData')

  canLoadMoreItems: (->
    nextPageInitIndex = @get('currentPage') * @get('perPage')
    return nextPageInitIndex < @get('feedData').length
  ).property('currentPage', 'perPage', 'feedData')

  actions:
    loadMoreItems: ->
      if @get('canLoadMoreItems')
        @set('isLoadingMoreItems', true)
        nextPageInitIndex = @get('currentPage') * @get('perPage')
        nextPageEndIndex = Math.min((nextPageInitIndex + @get('perPage')), @get('feedData').length)
        @incrementProperty('currentPage')
        Ember.run.later this, (=>
          @lazyLoadedItems.pushObjects(@get('feedData').slice(nextPageInitIndex, nextPageEndIndex))
          @set('isLoadingMoreItems', false)
        ), 500
)

# TODO - fix the targetting

RssReader.LazyLoaderView = Ember.View.extend(
  Ember.ViewTargetActionSupport
  templateName: "lazy-loader-template"
  didInsertElement: ->
    @$().bind "inview", (event, isInView, visiblePartX, visiblePartY) =>
      if isInView
        Ember.run.later this, (=>
          @triggerAction(
            action: "loadMoreItems"
            target: @get('this._parentView._parentView._parentView')
          )
        ), 200
)

RssReader.FeedItemsView = Ember.View.extend(
  templateName: "feed-items-template"
  didInsertElement: ->
    imgSelector = ".itemContent img"
    lazyLoaderEffect = "fadeIn"
    @$(imgSelector).each (index) ->
      $(this).attr("data-original", $(this).attr("src"))
      $(this).removeAttr("src")
      $(this).lazyload(effect: lazyLoaderEffect)
)

