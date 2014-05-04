RssReader.FeedsController = Ember.ArrayController.extend
  sortProperties: [ "name" ]
  sortAscending: true
  filteredContent: (->
    content = @get("arrangedContent")
  ).property("arrangedContent.@each")

RssReader.FeedsNewController = Ember.ObjectController.extend
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

