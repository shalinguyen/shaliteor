# redo this ;)
relative_time = (time_value) ->
  values = time_value.split(" ")
  time_value = values[1] + " " + values[2] + ", " + values[5] + " " + values[3]
  parsed_date = Date.parse(time_value)
  relative_to = (if (arguments.length > 1) then arguments[1] else new Date())
  delta = parseInt((relative_to.getTime() - parsed_date) / 1000)
  delta = delta + (relative_to.getTimezoneOffset() * 60)
  if delta < 60
    "less than a minute ago"
  else if delta < 120
    "about a minute ago"
  else if delta < (60 * 60)
    (parseInt(delta / 60)).toString() + " minutes ago"
  else if delta < (120 * 60)
    "about an hour ago"
  else if delta < (24 * 60 * 60)
    "about " + (parseInt(delta / 3600)).toString() + " hours ago"
  else if delta < (48 * 60 * 60)
    "1 day ago"
  else
    (parseInt(delta / 86400)).toString() + " days ago"

Template.page.selectedPage = ->
  selectedPage = Session.get("selectedPage")
  Template[selectedPage]() if selectedPage

Template.page.selectedPageName = ->
  Session.get "selectedPage"

# Template.page.preserve([".js-preserve"]);
Template.portfolio.selectedPortfolioPage = ->
  selectedPortfolioPage = Session.get("selectedPortfolioPage")
  Template[selectedPortfolioPage]() if selectedPortfolioPage

Template.navigation.pageActiveClass = (pageName) ->
  (if Session.get("selectedPage") is pageName then "active" else "")

Template.portfolio.portfolioNavigationClass = ->
  (if Session.get("selectedPortfolioPage") then "detail-view" else "list-view")

Template.portfolio.preserve [".js-preserve"]

Template.footer.rendered = ->
  $.ajax "http://api.twitter.com/1/statuses/user_timeline/shalinguyen.json",
    data:
      count: 1
    dataType: "jsonp"
    success: (twitters) =>
      statusHTML = []
      i = 0

      # this is all kinda silly if we only care about the most recent tweet

      while i < twitters.length
        username = twitters[i].user.screen_name
        status = twitters[i].text.replace(/((https?|s?ftp|ssh)\:\/\/[^"\s\<\>]*[^.,;'">\:\s\<\>\)\]\!])/g, (url) ->
          "<a href=\"" + url + "\">" + url + "</a>"
        ).replace(/\B@([_a-z0-9]+)/g, (reply) ->
          reply.charAt(0) + "<a href=\"http://twitter.com/" + reply.substring(1) + "\">" + reply.substring(1) + "</a>"
        )
        statusHTML.push "<span>" + status + "</span> <a class=\"twitter-username\" href=\"http://twitter.com/" + username + "/statuses/" + twitters[i].id_str + "\">" + relative_time(twitters[i].created_at) + "</a>"
        i++

      @find("#s-recent-tweets").innerHTML = statusHTML.join("")

  Template.zerocater.rendered = ->
    $.getScript "//platform.twitter.com/widgets.js"

Meteor.startup ->
  PageRouter = Backbone.Router.extend
    routes:
      "": "portfolio"
      "portfolio": "portfolio"
      "portfolio/:section": "portfolio"
      "contact": "contact"
      "about": "about"

    initialize: (options) ->
      $body = $("body")

      @on "all", (route, params...) ->
        params.unshift(route.split(":")[1])
        $body.attr "class", params.join(" ")

    about: ->
      Session.set "selectedPage", "about"

    contact: ->
      Session.set "selectedPage", "contact"

    portfolio: (pageName) ->
      Session.set "selectedPage", "portfolio"
      Session.set "selectedPortfolioPage", pageName

  router = new PageRouter
  Backbone.history.start pushState: true

  skrollr.init
    forceHeight: false


# All navigation that is relative should be passed through the navigate
# method, to be processed by the router. If the link has a `data-bypass`
# attribute, bypass the delegation completely.
$(document).on "click", "a[href]:not([data-bypass])", (evt) ->

  # Get the absolute anchor href.
  href =
    prop: $(this).prop("href")
    attr: $(this).attr("href")


  # Get the absolute root.
  root = location.protocol + "//" + location.host + "/" #app.root;

  # Ensure the root is part of the anchor href, meaning it's relative.
  if href.prop.slice(0, root.length) is root

    # Stop the default event to ensure the link will not cause a page
    # refresh.
    evt.preventDefault()

    # `Backbone.history.navigate` is sufficient for all Routers and will
    # trigger the correct events. The Router's internal `navigate` method
    # calls this anyways.  The fragment is sliced from the root.
    Backbone.history.navigate href.attr, true