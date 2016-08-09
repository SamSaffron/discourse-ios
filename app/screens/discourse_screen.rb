class DiscourseScreen < UIViewController
  extend IB

  attr_accessor :site
  attr_reader :configuration

  def viewDidLoad
    super
    url = NSURL.URLWithString(site.url)
    url_request = NSURLRequest.requestWithURL(url)
    web_view.loadRequest(url_request)

    self.view.addSubview(web_view)
    self.title = site.name
  end

  def webView(web_view, didStartProvisionalNavigation:navigation)
  end

  def webView(web_view, didFinishNavigation:navigation)

    # store = WKWebsiteDataStore.defaultDataStore
    # store.fetchDataRecordsOfTypes(
    #   NSSet.setWithArray([WKWebsiteDataTypeCookies]),
    #   completionHandler: proc{ |records|
    #     records.each do |record|
    #       p record.displayName
    #       p record.dataTypes.allObjects
    #     end
    # })
    @configuration.processPool = WKProcessPool.alloc.init
    p NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies
  end

  def webView(web_view, decidePolicyForNavigationAction: action, decisionHandler: handler)
    p action.request.allHTTPHeaderFields
    handler.call WKNavigationResponsePolicyAllow
  end

  def webView(web_view, didFailNavigation:navigation, withError:error)
  end

  def web_view
    @web_view ||= build_web_view
  end

  def build_web_view
    @configuration = WKWebViewConfiguration.alloc.init
    @configuration.processPool = WKProcessPool.alloc.init
    # #
    # dataTypes = NSSet.setWithArray([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
    #
    # WKWebsiteDataStore.defaultDataStore.removeDataOfTypes(dataTypes, modifiedSince: NSDate.distantPast, completionHandler: proc{})
    #
    # puts "HELLO"

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

    @configuration.userContentController = controller

    view = WKWebView.alloc.initWithFrame(self.view.frame, configuration: @configuration)
    view.navigationDelegate = self
    view
  end
end
