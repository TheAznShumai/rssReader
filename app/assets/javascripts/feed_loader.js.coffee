$ ->
  $.fn.Feed = (params) ->
    feed = $.extend(
      FeedUrl: ""
      MaxCount: 25
      ShowDesc: true
      ShowPubDate: true
      CharacterLimit: 0
      TitleLinkTarget: "_blank"
      DateFormat: ""
      DateFormatLang:"en"
    , params)

    id = $(this).attr("id")
    $("#" + id).empty().append('<i class="fa fa-spinner fa-spin fa-5x" id="feed-loader-icon"></i>')

    $.ajax(
      url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + def.MaxCount + "&output=json&q=" + encodeURIComponent(def.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
      dataType: "json"
      success: (data) ->
        $("#" + id).empty()

