# For more information see: http://emberjs.com/guides/routing/

RssReader.Router.map ->
  this.resource "feeds", ->
    this.route "show", { path: ":feed_id" }
    this.route "new"

