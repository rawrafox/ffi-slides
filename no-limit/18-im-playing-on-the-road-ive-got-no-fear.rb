require "./19-the-sound-from-my-mouth-is-on-record-here.rb"

module Java
  class FieldID < Demo::ConvertedObject
  end

  class MethodID < Demo::ConvertedObject
  end

  class Environment < FFI::Struct
    layout :f, :pointer
  end

  class Functions < FFI::Pointer
    F = ->(x) { x.respond_to?(:to_ffi_type) ? x.to_ffi_type : x } unless __FILE__ == $0

    def f(return_value, arguments, n, *argv)
      FFI::Function.new(F.call(return_value), [Environment.by_ref] + arguments.map(&F), self.get_pointer(n * FFI::Pointer::SIZE)).call(Thread.current[:env], *argv)
    end

    def exception_describe
      f(:int, [], 16)
    end

    def call_object_method(object, method, arguments)
      f(F.call(Object), [Object, MethodID, *arguments.map(&F)], 34, object, method, *arguments)
    end

    def call_void_method(object, method, arguments)
      f(:void, [Object, MethodID, *arguments.map(&F)], 61, object, method, *arguments)
    end

    def call_static_object_method(object, method, arguments)
      f(F.call(Object), [Class, MethodID, *arguments.map(&F)], 114, object, method, *arguments)
    end

    def exception_check
      f(:int, [], 228)
    end
  end

  def self.exception_check
    if self.vtable.exception_check != 0
      self.vtable.exception_describe

      raise Exception, "unhandled for now"
    end
  end

  def self.find_class(name)
    self.vtable.find_class(name)
  end

  def self.string(string)
    s = string.encode("UTF-16LE")

    self.vtable.f(Object, [:string, :size_t], 163, s, s.bytesize / 2)
  end

  def self.read_string(string)
    self.vtable.f(:string, [Object, :pointer], 169, string, nil)
  end
end

if __FILE__ == $0
  puts Java.string("I'm playing on the road. I've got no fear").to_s
end
