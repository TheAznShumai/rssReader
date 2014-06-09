Ember.Handlebars.registerBoundHelper("moment", (date) ->
  formattedDate = ""
  isoDate = new Date(date).toISOString()
  formattedDate = moment(isoDate).format('llll') if typeof isoDate isnt "undefined"
  return formattedDate
)

