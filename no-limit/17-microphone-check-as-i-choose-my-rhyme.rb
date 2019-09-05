require "./16-no-limits-allowed-cause-theres-much-crowd.rb" unless __FILE__ == $0
require "./19-the-sound-from-my-mouth-is-on-record-here.rb"

module Java
  class Class < Object
    def self.find(name)
      Java.vtable.f(Class, [:string], 6, name)
    end

    def static_field_id(name, signature)
      Java.vtable.f(FieldID, [Class, :string, :string], 144, self, name, signature)
    end

    def static_method_id(name, signature)
      Java.vtable.f(MethodID, [Class, :string, :string], 113, self, name, signature)
    end

    def method_id(name, signature)
      Java.vtable.f(MethodID, [Class, :string, :string], 33, self, name, signature)
    end

    def read_field(name, signature)
      case signature
      when /\AL/
        Java.vtable.f(Object, [Class, FieldID], 145, self, self.static_field_id(name, signature))
      else
        raise
      end
    end

    def reflected_field_id(name)
      field = self.java_call("getField", "(Ljava/lang/String;)Ljava/lang/reflect/Field;", Java.string(name))

      Java.vtable.f(FieldID, [Object], 8, field)
    end

    def field(name)
      Java.vtable.f(Object, [Class, FieldID], 145, self, reflected_field_id(name))
    end

    def java_static_call(op, signature, *arguments)
      mid = self.static_method_id(op, signature).tap { Java.exception_check }

      super unless mid.raw != 0

      Java.vtable.call_static_object_method(self, mid, arguments).tap { Java.exception_check }
    end

    def method_missing(op, *args)
      if args.count == 0
        if fid = self.reflected_field_id(op.to_s)
          return Java.vtable.f(Object, [Class, FieldID], 145, self, fid)
        end
      end

      super
    end
  end
end

if __FILE__ == $0
  System.out.java_call(:println, "(Ljava/lang/String;)V", Java.string("Microphone check as I choose my rhyme"))
end
