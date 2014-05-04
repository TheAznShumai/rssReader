RssReader.FeedsController = Ember.ArrayController.extend
  sortProperties: [ "name" ]
  sortAscending: true
  filteredContent: (->
    content = @get("arrangedContent")
    content.filter (item, index, self) ->
      not (item.get("isNew"))
  ).property("arrangedContent.@each")


