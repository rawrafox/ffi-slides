require "base64"
require "erb"

require "./12-tick-tick-ticka-tick-take-your-time.rb"

module WebKit
  extend FFI::Library

  ffi_lib "/System/Library/Frameworks/WebKit.framework/WebKit"
end

NSURL = ObjectiveC::Class.find("NSURL")
NSURLRequest = ObjectiveC::Class.find("NSURLRequest")
WKWebView = ObjectiveC::Class.find("WKWebView")
WKWebViewConfiguration = ObjectiveC::Class.find("WKWebViewConfiguration")
WKUserContentController = ObjectiveC::Class.find("WKUserContentController")

if __FILE__ == $0
  JSDelegate = ObjectiveC::Class.allocate_pair(ObjectiveC::Class.find("NSObject"), "JSDelegate", 0).tap do |js|
    js.add_method("userContentController:didReceiveScriptMessage:", "v", "@", "@") do |_, _, _, message|
      pp message.body
    end

    js.register
  end

  html = NSString.alloc.initWithUTF8String(<<~HTML)
<html><body><script>window.f = function() { msg = "When I'm going, I'm going for mine"; window.webkit.messageHandlers.demo.postMessage(msg); document.write(msg) }</script><button onclick="f()">Click</button></body></html>
HTML

  config = WKWebViewConfiguration.alloc.init
  config.setUserContentController(WKUserContentController.alloc.init)
  config.userContentController.addScriptMessageHandler(JSDelegate.alloc.init, name: NSString.alloc.initWithUTF8String("demo"))

  webview = WKWebView.alloc.initWithFrame(RECT, configuration: config)
  webview.loadHTMLString(html, baseURL: NSURL.alloc.initWithString(NSString.alloc.initWithUTF8String("file:/#{__dir__}")))

  Window.contentView.addSubview(webview)

  NSApplication.sharedApplication.tap { |app| app.setActivationPolicy(0); app.activateIgnoringOtherApps(1) }.run
end
