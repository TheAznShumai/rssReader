$ ->
  $.fn.Feeds = (params) ->
    feed = $.extend(
      FeedUrl: ""
      MaxCount: 25
      CharacterLimit: 0
      DateFormat: ""
      DateFormatLang: "en"
    , params)
    id = $(this).attr("id")
    $("#" + id).empty().append('<i class="fa fa-spinner fa-spin fa-5x" id="feed-loader-icon"></i>')

    panelPreface = '<div class="panel panel-default"><div class="panel-heading"><h4 class="panel-title"><a data-toggle="collapse" data-parent="#accordion" href='
    panelAppendix = '</a></h4></div>'

    $.ajax(
      url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + feed.MaxCount + "&output=json&q=" + encodeURIComponent(feed.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
      dataType: "json"
      success: (data) ->
        content = '<div class="panel-group">'
        $("#" + id).empty()
        if data.responseData != null
          $.each data.responseData.feed.entries, (event, item) ->
            debugger
            content += panelPreface + '"#' + item.title + '">'
            content += '<li><div class="itemTitle"><a href="' + item.link + '" target="_blank">' + item.title + "</a></div>"
            itemDate = new Date(item.publishedDate)
            if $.trim(feed.DateFormat).length > 0
              try
                moment.lang(feed.DateFormatLang)
                content += '<div class="itemDate">' + moment(itemDate).format(feed.DateFormat) + "</div>"
              catch
                content += '<div class="itemDate">' + itemDate.toLocaleDateString() + "</div>"
            if feed.CharacterLimit > 0 && item.content.length > feed.CharacterLimit
              panelContent = item.content.substr(0, feed.DescCharacterLimit) + "..."
            else
              panelContent = item.content
            content += '<div class="itemContent">' + panelContent + "</div>"
          content += "</div>"
          $("#" + id).append('<ul class="rssFeedList list-unstyled">' + content + "</ul>")
        else
          $("#" + id).append('<h4><i>No Feed Found for "' + feed.FeedUrl + '".<i></h4>')
    )

