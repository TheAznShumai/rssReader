RssReader.FeedCollectionView = Ember.CollectionView.extend(
  itemsUpdateLimit: 25

  init: ->
    Ember.run.next this, =>
      @get('controller').send('loadRssFeed')
      @pushObject(RssReader.FeedView.create(id: @get('controller.content.id')))

  idDidChange: (->
    viewIndex = @get('viewIndex')
    @send('hideAllChildren')
    if Ember.isBlank(viewIndex)
      @pushObject(RssReader.FeedView.create(id: @get('controller.content.id'), lazyLoadedItems: []))
    else
      @send('showChildWithId', @get('controller.id'))
    @get('controller').send('loadRssFeed')
  ).observes('controller.id')

  viewIndex: (->
    viewIndex = null
    @get('childViews').forEach (view, index) =>
      viewIndex = index if view.id == @get('controller.id')
    return viewIndex
  ).property('childViews', 'controller.id')

  # TODO - Optimize the process more and fix viewIndex

  feedDataDidChange: (->
    feedData = @get('controller.feedData')
    if not Ember.isBlank(feedData)
      childView = @get('childViews')[@get('viewIndex')]
      if not Ember.isBlank(childView)
        if Ember.isBlank(childView.feedData)
          childView.set('feedData', feedData)
        else
          lazyLoadedItems = childView.lazyLoadedItems
          if !isFeedObjectEql(lazyLoadedItems[0], feedData[0])
            newItemsEndIndex = 0
            limit = @get('itemsUpdateLimit')
            newItemsEndIndex++ while !isFeedObjectEql(lazyLoadedItems[0], feedData[newItemsEndIndex]) &&
                                      newItemsEndIndex < feedData.length &&
                                      newItemsEndIndex < limit
            if newItemsEndIndex < limit
              lazyLoadedItems.unshiftObjects(feedData.slice(0, newItemsEndIndex))
            else
              childView.initialize(feedData)
  ).observes('controller.feedData')

  actions:
    showChildWithId: (id) ->
      Ember.run this, =>
        @get('childViews').forEach (view, index) ->
          view.set('isVisible', true) if view.id == id and not view.isVisible
    hideAllChildren: ->
      Ember.run this, =>
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

  initialize: (feedData) ->
    Ember.run.next this, (->
      @set('feedData', feedData)
      @set('lazyLoadedItems', [])
      @set('currentPage', 0)
    )

  isInitialized: (->
    return @get('currentPage') > 0
  ).property('currentPage')

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
        Ember.run.later this, (=>
          @lazyLoadedItems.pushObjects(@get('feedData').slice(nextPageInitIndex, nextPageEndIndex))
          @incrementProperty('currentPage')
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

# TODO - find a home for this helper function

isFeedObjectEql = (obj1, obj2) ->
  return obj1.title == obj2.title && obj1.link == obj2.link && obj1.publishedDate == obj2.publishedDate

