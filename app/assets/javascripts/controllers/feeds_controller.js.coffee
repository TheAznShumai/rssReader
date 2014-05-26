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
  isFeedEmpty: false
  isFeedLoading: false
  isFeedLoaded: false
  feedData: []
  maxItemsCount: 50

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
      @set('isFeedLoading', true)
      @set('isFeedLoaded', false)
      @set('isFeedEmpty', false)
      request = loadFeed(FeedUrl: @get('url'), MaxItemsCount: @get('maxItemsCount'))
      request.success (data) =>
        if data.responseData != null
          @set('feedData', data.responseData.feed.entries)
        else
          @set('isFeedEmpty', true)
        @set('isFeedLoading', false)
        @set('isFeedLoaded', true)
)

loadFeed = (params) ->
  feed = $.extend(
    FeedUrl: ""
    MaxItemsCount: 25
  , params)

  return $.ajax(
    url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + feed.MaxItemsCount + "&output=json&q=" + encodeURIComponent(feed.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
    dataType: "json")

