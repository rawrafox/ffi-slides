require_relative "024-objective-c-method-missing"

module Cocoa
  extend FFI::Library

  ffi_lib "/System/Library/Frameworks/Cocoa.framework/Cocoa"

  attach_variable :NSWindowWillCloseNotification, ObjectiveC::Object
end

class CGPoint < FFI::Struct
  layout :x, :double, :y, :double
end

class CGSize < FFI::Struct
  layout :width, :double, :height, :double
end

class CGRect < FFI::Struct
  layout :origin, CGPoint, :size, CGSize
end

NSApplication = ObjectiveC::Class.find("NSApplication")
NSImage = ObjectiveC::Class.find("NSImage")
NSNotificationCenter = ObjectiveC::Class.find("NSNotificationCenter")
NSWindow = ObjectiveC::Class.find("NSWindow")
NSImageView = ObjectiveC::Class.find("NSImageView")
