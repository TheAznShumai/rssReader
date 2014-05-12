RssReader.LoadRssFeedView = Ember.View.extend(
  template: Ember.Handlebars.compile('<div class="container-fluid" id="divRss"></div>')
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
RssReader.RssFeedItemView = Ember.View.extend(
  templateName: 'feed_item'
)
