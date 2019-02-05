require "ffi"

require "./19-the-sound-from-my-mouth-is-on-record-here.rb"

module Java
  class Object < Demo::ConvertedObject
    def java_class
      Java.vtable.f(Class, [Object], 31, self)
    end

    def java_call(op, signature, *arguments)
      mid = self.java_class.method_id(op.to_s, signature).tap { Java.exception_check }

      super unless mid.raw != 0

      case signature[-1]
      when "V" then Java.vtable.call_void_method(self, mid, arguments)
      when ";" then Java.vtable.call_object_method(self, mid, arguments)
      else
        raise
      end.tap { Java.exception_check }
    end

    def to_s
      Java.read_string(self.java_call("toString", "()Ljava/lang/String;"))
    end
  end
end

if __FILE__ == $0
  System.read_field("out", "Ljava/io/PrintStream;").java_call(:println, "(Ljava/lang/String;)V", Java.string("No limits allowed, cause there's much crowd"))
end
