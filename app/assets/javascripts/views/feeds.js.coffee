RssReader.RssFeedView = Ember.View.extend(
  template: Ember.Handlebars.compile('<div id="divRss"></div>'),
  init: (->
    Ember.run.later this, (->
      $('#divRss').FeedEk(FeedUrl : @get('controller.url'))
    ), 100
  )
  urlDidChange: (->
    Ember.run.next this, ->
      $('#divRss').FeedEk(FeedUrl : @get('controller.url'))
  ).observes(null, 'controller.url')
)

