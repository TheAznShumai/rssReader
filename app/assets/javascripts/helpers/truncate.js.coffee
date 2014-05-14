Ember.Handlebars.registerBoundHelper("truncate", (str, len) ->
  if str.length > len and str.length > 0
    new_str = str + " "
    new_str = str.substr(0, len)
    new_str = str.substr(0, new_str.lastIndexOf(" "))
    new_str = (if (new_str.length > 0) then new_str else str.substr(0, len))
    return new Handlebars.SafeString(new_str + "...")
  return str
)

