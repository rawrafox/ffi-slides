require_relative "025-objective-c-cocoa"

NSAutoreleasePool.alloc.init

rect = CGRect.new
rect[:size][:width] = 768.0
rect[:size][:height] = 1024.0

view = NSImageView.alloc.initWithFrame(rect)
view.setImage(NSImage.alloc.initWithContentsOfFile(NSString.alloc.initWithUTF8String("standard-issue-swedish-shark.jpg")))

window = NSWindow.alloc.initWithContentRect(rect, styleMask: 7, backing: 2, defer: 0)
window.makeKeyAndOrderFront(nil)
window.setTitle(NSString.alloc.initWithUTF8String("Standard-issue Swedish Shark"))
window.contentView.addSubview(view)

NSApplication.sharedApplication.tap do |app|
  app.setActivationPolicy(0)
  app.activateIgnoringOtherApps(1)

  NSNotificationCenter.defaultCenter.addObserver(app, selector: "terminate:", name: Cocoa.NSWindowWillCloseNotification, object: window)
end.run
