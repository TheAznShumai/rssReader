Ember.Handlebars.registerBoundHelper("moment", (date) ->
  return moment(date).format('llll')
)

