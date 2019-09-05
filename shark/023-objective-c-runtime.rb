require "ffi"

require_relative "022-objective-c-types"

module ObjectiveC
  class Selector < RuntimeObject
    def self.to_native(value, _)
      case value
      when self then value.pointer
      when String, Symbol then self.register(value).pointer
      else
        raise TypeError, "expected a kind of #{self.name} was #{value.class}"
      end
    end

    singleton_function :register, "sel_registerName", [:string], Selector

    instance_function :name, "sel_getName", [], :string

    def to_s
      self.name
    end
  end

  class Method < RuntimeObject
    instance_function :argument_count, "method_getNumberOfArguments", [], :uint
    instance_function :implementation, "method_getImplementation", [], :pointer
    instance_function :objc_argument_type, "method_copyArgumentType", [:uint], :string
    instance_function :objc_return_type, "method_copyReturnType", [], :string

    def arguments
      self.argument_count.times.map { |i| self.argument_type(i) }
    end

    def argument_type(i)
      Types.lookup(self.objc_argument_type(i))
    end

    def return_type
      Types.lookup(self.objc_return_type)
    end

    def to_proc
      @function ||= Helper.function(self.implementation, self.arguments, self.return_type)
    end

    def call(*args)
      self.to_proc.call(*args)
    end
  end

  class Class < Object
    singleton_function :allocate_pair, "objc_allocateClassPair", [Class, :string, :size_t], Class
    singleton_function :find, "objc_getClass", [:string], Class

    instance_function :objc_class_method, "class_getClassMethod", [Selector], Method
    instance_function :objc_instance_method, "class_getInstanceMethod", [Selector], Method
  end

  class Object < RuntimeObject
    instance_function :objc_class, "object_getClass", [], Class

    def objc_method(selector)
      self.objc_class.objc_instance_method(selector)
    end
  end
end
