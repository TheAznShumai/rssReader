RssReader.FeedsController = Ember.ArrayController.extend(
  sortProperties: ['name']
  sortAscending: true
  filteredContent: (->
    content = @get('arrangedContent')
  ).property('arrangedContent.@each')
)

RssReader.FeedsNewController = Ember.ObjectController.extend(
  actions:
    submit: ->
      @get('model').save().then (=>
        @transitionToRoute('feeds.show', @get('model').id)
      ), (error) =>
        @get('model').rollback()
        alert 'An Error Occured'
        console.log(error)

    cancel: ->
      @get('content').deleteRecord()
      @get('model').rollback()
      @transitionToRoute('feeds')
)

RssReader.FeedsShowController = Ember.ObjectController.extend(
  RssReader.BootstrapAccordion

  isEditing: false
  isFeedLoading: false
  isFeedLoaded: false
  feedData: []
  maxItemsCount: 300
  poller: null

  pushRssData: ->
    @set('isFeedLoading', true)
    @set('isFeedLoaded', false)
    feed_id = @get('id')
    loadFeedPromise = loadFeed(FeedUrl: @get('url'), MaxItemsCount: @get('maxItemsCount'))
    loadFeedPromise.then ((data) =>
    # Do nothing if we recieve a response that doesn't match the current feed id route
    # This solves the issue where the transitions too quickly before loadFeed finishes for a route
      if @get('id') == feed_id
        content = if data.responseData != null then cleanContent(data.responseData.feed.entries) else []
        @set('feedData', content)
        @set('isFeedLoading', false)
        @set('isFeedLoaded', true)
    ), (error) =>
      alert 'Error in the RssData'

  actions:
    edit: ->
      @set('isEditing', true)

    cancel: ->
      if @get('model').get('isDirty')
        if confirm("You have unsaved changes. They will be lost if you continue!")
          @get('model').rollback()
          @set('isEditing', false)
      else
        @set('isEditing', false)

    submit: ->
      if @get('model').get('isDirty')
        @get('model').save().then (=>
          @set('isEditing', false)
          @transitionToRoute('feeds.show', @get('model').id)
          @send('loadRssFeed')
        ), (error) =>
          @get('model').rollback()
          alert 'An Error Occured'
          console.log(error)
      else
        @send('cancel')

    delete: ->
      if confirm("Are you sure you want to delete this feed?")
        @get('model').deleteRecord()
        @get('model').save()
        @transitionToRoute('feeds')
        @set('isEditing', false)

    loadRssFeed: ->
      @pushRssData()
      if !Ember.isBlank(@get('poller'))
        @get('poller').stopPoll()
        @get('poller').destroy()
      @set('poller', RssReader.Poller.create(
        onPoll: =>
          @pushRssData() if !(@get('isFeedLoading') == false &&
                              @get('isFeedLoaded') == true &&
                              Ember.isEmpty(@get('feedData')))
      ))
      @get('poller').startPoll()

)

#TODO - organize me please

cleanContent = (feed) ->
  # The append is for jquery to process feeds that start with text instead of a tag
  if Ember.isBlank($($('<div></div>').append(feed[0]['content'])).text())
    return feed.map (item) ->
      delete item["content"]
      return item
  else
    return feed

loadFeed = (params) ->
  feed = $.extend(
    FeedUrl: ""
    MaxItemsCount: 25
  , params)

  return $.when($.ajax(
    url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + feed.MaxItemsCount + "&output=json&q=" + encodeURIComponent(feed.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
    dataType: "json"))

