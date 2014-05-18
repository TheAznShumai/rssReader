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
    self = this
    this.$().bind "inview", (event, isInView, visiblePartX, visiblePartY) ->
      if isInView
        Ember.run.later this, (->
          self.triggerAction()
        ), 200
)

