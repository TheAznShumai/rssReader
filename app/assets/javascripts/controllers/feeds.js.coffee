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
  rssFeed: null
  actions:
    edit: ->
      @set('isEditing', true)

    cancel: ->
      if @get('model').get('isDirty')
        if confirm("You have unsaved changes. They will be lost if you continue!")
          @get('model').rollback()
      @set('isEditing', false)

    submit: ->
      self = this
      if @get('model').get('isDirty')
        @get('model').save().then (->
          self.set('isEditing', false)
          self.transitionToRoute('feeds.show', self.get('model').id)
          self.send('loadRss')
        ), (error) ->
          @get('model').rollback()
          alert 'An Error Occured'
          console.log(error)

    delete: ->
      if confirm("Are you sure you want to delete this feed?")
        @get('model').deleteRecord()
        @get('model').save()
        @transitionToRoute('feeds')
        @set('isEditing', false)

    loadRss: ->
      self = this
      url = @get('url')
      yql = 'http://query.yahooapis.com/v1/public/yql?q=' + encodeURIComponent('select * from xml where url="' + url + '"') + '&format=xml&callback=?';
      $.getJSON yql, (data) ->
        self.set('rssFeed', if data.results[0] then data.results[0] else null)
)

