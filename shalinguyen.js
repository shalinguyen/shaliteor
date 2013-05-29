if (Meteor.isClient) {

  Template.page.selectedPage = function () {
    var selectedPage = Session.get("selectedPage");
    if (selectedPage) {
      return Template[selectedPage]();
    }
  };

  Template.page.selectedPageName = function () {
    return Session.get("selectedPage");
  };

  // Template.page.preserve([".js-preserve"]);

  Template.portfolio.selectedPortfolioPage = function () {
    var selectedPortfolioPage = Session.get("selectedPortfolioPage");
    if (selectedPortfolioPage) {
      return Template[selectedPortfolioPage]();
    }
  };

  Template.navigation.pageActiveClass = function(pageName) {
    return Session.get("selectedPage") === pageName ? "active" : "";
  };

  Template.portfolio.portfolioNavigationClass = function() {
    return Session.get("selectedPortfolioPage") ? "detail-view" : "list-view";
  };

  Template.portfolio.preserve([".js-preserve"]);

  var PageRouter = Backbone.Router.extend({
    routes: {
      "": "portfolioPage",
      "portfolio": "portfolioPage",
      "portfolio/:section": "portfolioPage",
      ":page": "topLevelPage"
    },
    topLevelPage: function(page) {
      Session.set("selectedPage", page);
    },
    portfolioPage: function(portfolioPage) {
      Session.set("selectedPage", "portfolio");
      Session.set("selectedPortfolioPage", portfolioPage);
    }
  });

  router = new PageRouter;

  Backbone.history.start({pushState: true});

  // All navigation that is relative should be passed through the navigate
  // method, to be processed by the router. If the link has a `data-bypass`
  // attribute, bypass the delegation completely.
  $(document).on("click", "a[href]:not([data-bypass])", function(evt) {
    // Get the absolute anchor href.
    var href = { prop: $(this).prop("href"), attr: $(this).attr("href") };
    // Get the absolute root.
    var root = location.protocol + "//" + location.host + "/";//app.root;

    // Ensure the root is part of the anchor href, meaning it's relative.
    if (href.prop.slice(0, root.length) === root) {
      // Stop the default event to ensure the link will not cause a page
      // refresh.
      evt.preventDefault();

      // `Backbone.history.navigate` is sufficient for all Routers and will
      // trigger the correct events. The Router's internal `navigate` method
      // calls this anyways.  The fragment is sliced from the root.
      Backbone.history.navigate(href.attr, true);
    }
  });

}

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}