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
        pathArray = params
        pathArray.reverse()
        pathArray.push(route.split(":")[1])
        pathArray.reverse()

        $body.attr "class", pathArray.join(" ")

    about: ->
      Session.set "selectedPage", "about"

    contact: ->
      Session.set "selectedPage", "contact"

    portfolio: (pageName) ->
      Session.set "selectedPage", "portfolio"
      Session.set "selectedPortfolioPage", pageName

  router = new PageRouter
  Backbone.history.start pushState: true


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