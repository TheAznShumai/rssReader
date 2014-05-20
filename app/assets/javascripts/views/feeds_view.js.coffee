RssReader.LoadRssFeedView = Ember.View.extend(
  init: (->
    Ember.run.later this, (->
      @get('controller').send('loadRssFeed')
    ), 100
  )
  idDidChange: (->
    Ember.run.next this, ->
      @get('controller').send('loadRssFeed')
  ).observes('controller.id')
)

RssReader.LazyLoaderView = Ember.View.extend(Ember.ViewTargetActionSupport,
  templateName: "lazy-loader-template"
  action: "loadMoreItems"
  didInsertElement: ->
    @$().bind "inview", (event, isInView, visiblePartX, visiblePartY) =>
      if isInView
        Ember.run.later this, (=>
          @triggerAction()
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

