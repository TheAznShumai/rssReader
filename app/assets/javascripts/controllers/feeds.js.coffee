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
  isEditing: false
  isFeedEmpty: false
  feedData: []
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

    collapseToggle: (id) ->
      $("#" + id).collapse('toggle')

    collapseAll: ->
      $(".collapse").collapse('hide')

    expandAll: ->
      $(".collapse").not(".in").collapse('show')

    loadRssFeed: ->
      self = this
      self.set('isFeedEmpty', false)
      self.set('feedData', [])
      loader = $('#loader')
      loader.empty().append('Loading Feed... <i class="fa fa-spinner fa-spin" id="feed-loader-icon"></i>')
      request = loadFeed(FeedUrl :@get('url'))
      request.success (data) ->
        loader.empty()
        if data.responseData != null
          self.set('feedData', data.responseData.feed.entries)
        else
          self.set('isFeedEmpty', true)
)

loadFeed = (params) ->
  feed = $.extend(
    FeedUrl: ""
    MaxCount: 25
  , params)

  return $.ajax(
    url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + feed.MaxCount + "&output=json&q=" + encodeURIComponent(feed.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
    dataType: "json")

