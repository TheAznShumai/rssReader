RssReader.FeedCollectionView = Ember.CollectionView.extend(
  init: ->
    Ember.run.later this, (->
      @get('controller').send('loadRssFeed')
    ), 100

  viewIndex: (->
    viewIndex = null
    @get('childViews').forEach (view, index) =>
      viewIndex = index if view.id == @get('controller.id')
    return viewIndex
  ).property().volatile()

  idDidChange: (->
    Ember.run.next this, ->
      @get('controller').send('loadRssFeed')
  ).observes('controller.id')

  # TODO - Optimize the process more and fix viewIndex
  feedDataDidChange: (->
    feedData = @get('controller.feedData')
    if not Ember.isBlank(feedData)
      if Ember.isBlank(@get('viewIndex'))
        @pushObject(RssReader.FeedView.create(
            id: @get('controller.content.id')
            feedData: feedData
        ))
      else
        #do stuff to add offset to the view and add element onto the current viewData
  ).observes('controller.feedData')
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

  canLoadMoreItems: (->
    nextPageInitIndex = @get('currentPage') * @get('perPage')
    return nextPageInitIndex < @get('feedData').length
  ).property().volatile()

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

