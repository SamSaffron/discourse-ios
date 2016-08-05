class DiscourseScreen < UIViewController
  extend IB

  attr_accessor :forum

  def viewDidLoad
    super
    url = NSURL.URLWithString(forum[:url])
    url_request = NSURLRequest.requestWithURL(url)
    web_view.loadRequest(url_request)

    self.view.addSubview(web_view)
  end

  def webView(web_view, didStartProvisionalNavigation:navigation)
  end

  def webView(web_view, didFinishNavigation:navigation)

    # TODO figure out how to grap cookies
    # p WKWebsiteDataStore.defaultDataStore.methods
    # WKWebsiteDataStore.defaultDataStore.fetchDataRecordsOfTypes(
    #   dataTypes: NSSet.setWithArray([WKWebsiteDataTypeCookies]),
    #   completionHandler: proc{|record| p record})
  end

  def webView(web_view, didFailNavigation:navigation, withError:error)
  end

  def web_view
    @web_view ||= build_web_view
  end

  def build_web_view
    configuration = WKWebViewConfiguration.alloc.init

    controller = WKUserContentController.alloc.init

    js = <<JS
    (function() {
      var methods = require('discourse/models/login-method').findAll(Discourse.SiteSettings);
      methods.forEach(function(method){
        method.set("fullScreenLogin", true);
      });
    })()
JS

    script = WKUserScript.alloc.initWithSource(js,
                injectionTime: WKUserScriptInjectionTimeAtDocumentEnd,
                forMainFrameOnly: true
    )

    controller.addUserScript script

    configuration.userContentController = controller

    view = WKWebView.alloc.initWithFrame(self.view.frame, configuration: configuration)
    view.navigationDelegate = self
    view
  end
end
