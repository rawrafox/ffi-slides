require_relative "031-java-environment"

module Java
  class Object < RuntimeObject
    def java_class
      Java.vtable.f(31, [Object], Class).call(self)
    end

    def java_call(op, signature, *arguments)
      mid = self.java_class.method_id(op.to_s, signature).tap { Java.exception_check }

      super if mid.pointer.null?

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
