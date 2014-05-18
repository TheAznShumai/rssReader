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
      self = this
      @get('model').save().then (->
        self.transitionToRoute('feeds.show', self.get('model').id)
      ), (error) ->
        @get('model').rollback()
        alert 'An Error Occured'
        console.log(error)

    cancel: ->
      @get('content').deleteRecord()
      @get('model').rollback()
      @transitionToRoute('feeds')
)

RssReader.FeedsShowController = Ember.ObjectController.extend(
  RssReader.LazyLoader
  RssReader.BootstrapAccordion

  isEditing: false
  isFeedEmpty: false
  isFeedLoading: false
  isFeedLoaded: false
  feedData: []
  maxItemsCount: 100

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
      self = this
      if @get('model').get('isDirty')
        @get('model').save().then (->
          self.set('isEditing', false)
          self.transitionToRoute('feeds.show', self.get('model').id)
          self.send('loadRssFeed')
        ), (error) ->
          @get('model').rollback()
          alert 'An Error Occured'
          console.log(error)
      else
        self.send('cancel')

    delete: ->
      if confirm("Are you sure you want to delete this feed?")
        @get('model').deleteRecord()
        @get('model').save()
        @transitionToRoute('feeds')
        @set('isEditing', false)

    loadRssFeed: ->
      self = this
      @set('isFeedLoading', true)
      @set('isFeedLoaded', false)
      @set('isFeedEmpty', false)
      @set('feedData', [])
      @send('initializeLazyLoader', 'feedData')
      request = loadFeed(FeedUrl :@get('url'), MaxItemsCount : @get('maxItemCount'))
      request.success (data) ->
        if data.responseData != null
          self.set('feedData', data.responseData.feed.entries)
        else
          self.set('isFeedEmpty', false)
        self.set('isFeedLoading', false)
        self.set('isFeedLoaded', true)
)

loadFeed = (params) ->
  feed = $.extend(
    FeedUrl: ""
    MaxItemsCount: 100
  , params)

  return $.ajax(
    url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + feed.MaxItemsCount + "&output=json&q=" + encodeURIComponent(feed.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
    dataType: "json")

