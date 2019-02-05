$LOADED_FEATURES << "#{__dir__}/#{__FILE__}" if __FILE__ == $0

require "./06-we-do-what-we-want-and-we-do-it-with-pride.rb"

module ObjectiveC
  extend FFI::Library
  ffi_lib "objc"

  Object = ::Class.new(Demo::ConvertedObject)
  Class = ::Class.new(ObjectiveC::Object)
  Selector = ::Class.new(Demo::ConvertedObject)
  Method = ::Class.new(Demo::ConvertedObject)

  attach_function :class_addMethod, [Class, Selector, :pointer, :string], :char
  attach_function :class_getClassMethod, [Class, Selector], Method
  attach_function :class_getInstanceMethod, [Class, Selector], Method

  attach_function :objc_allocateClassPair, [Class, :string, :size_t], Class
  attach_function :objc_getClass, [:string], Class
  attach_function :objc_registerClassPair, [Class], :void 

  attach_function :object_getClass, [Object], Class

  attach_function :method_copyArgumentType, [Method, :uint], :string
  attach_function :method_copyReturnType, [Method], :string
  attach_function :method_getImplementation, [Method], :pointer
  attach_function :method_getNumberOfArguments, [Method], :uint

  attach_function :sel_registerName, [:string], Selector
  attach_function :sel_getName, [Selector], :string
end

require "./10-i-work-real-hard-to-collect-my-cash.rb"
require "./11-im-on-the-edge-i-know-the-ledge.rb"
require "./09-im-on-the-ass-i-know-the-last.rb"
require "./08-when-im-on-stage-yo-youll-ask-for-more.rb"
require "./07-hard-to-the-core-i-feel-the-floor.rb"

NSApplication = ObjectiveC::Class.find("NSApplication")
NSData = ObjectiveC::Class.find("NSData")
NSString = ObjectiveC::Class.find("NSString")

ObjectiveC::Class.find("NSAutoreleasePool").alloc.init

Window = ObjectiveC::Class.find("NSWindow").alloc.initWithContentRect(RECT, styleMask: 7, backing: 2, defer: 0).autorelease
Window.makeKeyAndOrderFront(nil)

ObjectiveC::Class.find("NSNotificationCenter").defaultCenter.addObserver(NSApplication.sharedApplication, selector: "terminate:", name: Cocoa.NSWindowWillCloseNotification, object: Window)

if __FILE__ == $0
  string = NSString.alloc.initWithUTF8String("Tick-tick-ticka-tick take your time!")

  Window.setTitle(string)
  Window.contentView.addSubview(ObjectiveC::Class.find("NSButton").alloc.initWithFrame(RECT).autorelease.tap { |b| b.setTarget(NSApplication.sharedApplication); b.setAction("terminate:"); b.setTitle(string) })

  NSApplication.sharedApplication.tap { |app| app.setActivationPolicy(0); app.activateIgnoringOtherApps(1) }.run
end
