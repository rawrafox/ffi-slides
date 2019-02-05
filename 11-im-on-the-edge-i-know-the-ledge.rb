require "./12-tick-tick-ticka-tick-take-your-time.rb"

module ObjectiveC
  class Selector < Demo::ConvertedObject
    def self.register(name)
      ObjectiveC.sel_registerName(name)
    end

    def self.to_native(value, _)
      value.is_a?(Symbol) || value.is_a?(String) ? ObjectiveC.sel_registerName(value.to_s).raw : super
    end

    def name
      ObjectiveC.sel_getName(self)
    end
  end
end

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

RECT = CGRect.new unless __FILE__ == $0
RECT[:size][:width] = 1280.0 # 1920.0 # 1024.0
RECT[:size][:height] = 720.0 # 1080.0 # 768.0

if __FILE__ == $0
  Window.setTitle(NSString.alloc.initWithUTF8String("I'm on the edge, I know the ledge"))

  NSApplication.sharedApplication.tap { |app| app.setActivationPolicy(0); app.activateIgnoringOtherApps(1) }.run
end
