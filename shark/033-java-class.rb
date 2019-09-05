require_relative "032-java-object"

module Java
  class Class < Object
    def self.find(name)
      Java.vtable.f(6, [:string], Class).call(name)
    end

    def static_field_id(name, signature)
      Java.vtable.f(144, [Class, :string, :string], FieldID).call(self, name, signature)
    end

    def static_method_id(name, signature)
      Java.vtable.f(113, [Class, :string, :string], MethodID).call(self, name, signature)
    end

    def method_id(name, signature)
      Java.vtable.f(33, [Class, :string, :string], MethodID).call(self, name, signature)
    end

    def read_field(name, signature)
      case signature
      when /\AL/
        Java.vtable.f(145, [Class, FieldID], Object).call(self, self.static_field_id(name, signature))
      else
        raise
      end
    end

    def reflected_field_id(name)
      field = self.java_call("getField", "(Ljava/lang/String;)Ljava/lang/reflect/Field;", Java.string(name))

      Java.vtable.f(8, [Object], FieldID).call(field)
    end

    def field(name)
      Java.vtable.f(145, [Class, FieldID], Object).call(self, reflected_field_id(name))
    end

    def java_static_call(op, signature, *arguments)
      mid = self.static_method_id(op, signature).tap { Java.exception_check }

      super unless mid

      Java.vtable.call_static_object_method(self, mid, arguments).tap { Java.exception_check }
    end

    def method_missing(op, *args)
      if args.count == 0
        if fid = self.reflected_field_id(op.to_s)
          return Java.vtable.f(145, [Class, FieldID], Object).call(self, fid)
        end
      end

      super
    end
  end
end
