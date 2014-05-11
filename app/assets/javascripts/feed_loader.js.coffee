$ ->
  $.fn.Feeds = (params) ->
    feed = $.extend(
      FeedUrl: ""
      MaxCount: 25
      CharacterLimit: 0
      DateFormat: ""
      DateFormatLang:"en"
    , params)

    id = $(this).attr("id")
    $("#" + id).empty().append('<i class="fa fa-spinner fa-spin fa-5x" id="feed-loader-icon"></i>')

    $.ajax(
      url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + feed.MaxCount + "&output=json&q=" + encodeURIComponent(feed.FeedUrl) + "&scoring=h" + "&hl=en&callback=?"
      dataType: "json"
      success: (data) ->
        $("#" + id).empty()
        if data.responseData != null
          $.each(data.responseData.feed.entries, (event, item) ->
            row += '<li><div class="itemTitle"><a href="' + item.link + '" target="_blank">' + item.title + "</a></div>"

            itemDate = new Date(item.publishedDate)
            if $.trim(feed.DateFormat).length > 0
              try
                moment.lang(feed.DateFormatLang)
                row += '<div class="itemDate">' + moment(itemDate).format(feed.DateFormat) + "</div>"
              catch(error)
                row += '<div class="itemDate">' + itemDate.toLocaleDateString() + "</div>"

            # Do content
            if feed.CharacterLimit > 0 && item.content.length > feed.CharacterLimit
              row += '<div class="itemContent">' + item.content.substr(0, feed.DescCharacterLimit) + "...</div>"
            else
              row += '<div class="itemContent">' + item.content + "</div>"

          $("#" + id).append('<ul class="feedEkList list-unstyled">' + s + "</ul>")
        else
          $("#" + id).append('<h4><i>No Feed Found for "' + feed.FeedUrl + '".<i></h4>')

