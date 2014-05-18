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

