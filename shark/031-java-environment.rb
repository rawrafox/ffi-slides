require_relative "030-java-runtime-object"

module Java
  class FieldID < RuntimeObject
  end

  class MethodID < RuntimeObject
  end

  class Environment < FFI::Struct
    layout :f, :pointer
  end

  class Functions < FFI::Pointer
    def f(n, arg_types, return_type, *argv)
      return_type = FFI.find_type(return_type)
      arg_types = arg_types.map { |e| FFI.find_type(e) }

      f = FFI::Function.new(return_type, [Environment.by_ref] + arg_types, self.get_pointer(n * FFI::Pointer::SIZE))
      
      if arg_types.length > 0
        f.method(:call).curry(arg_types.length + 1).call(Thread.current[:env])
      else
        ->() { f.call(Thread.current[:env]) }
      end
    end

    def exception_describe
      f(16, [], :int).call(argv)
    end

    def call_object_method(object, method, arguments)
      f(34, [Object, MethodID, *arguments.map(&:class)], Object).call(object, method, *arguments)
    end

    def call_void_method(object, method, arguments)
      f(61, [Object, MethodID, *arguments.map(&:class)], :void).call(object, method, *arguments)
    end

    def call_static_object_method(object, method, arguments)
      f(114, [Class, MethodID, *arguments.map(&:class)], Object).call(object, method, *arguments)
    end

    def exception_check
      f(228, [], :int).call
    end
  end

  def self.vtable
    Thread.current[:vtable]
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

    self.vtable.f(163, [:string, :size_t], Object).call(s, s.bytesize / 2)
  end

  def self.read_string(string)
    self.vtable.f(169, [Object, :pointer], :string).call(string, nil)
  end
end
