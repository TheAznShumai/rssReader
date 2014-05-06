RssReader.RssFeedView = Ember.View.extend(
  template: Ember.Handlebars.compile('<div id="divRss"></div>')
  init: (->
    Ember.run.later this, (->
      @get('controller').send('loadRssFeed')
    ), 100
  )
  urlDidChange: (->
    Ember.run.next this, ->
      @get('controller').send('loadRssFeed')
  ).observes(null, 'controller.url')
)

