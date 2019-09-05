require_relative "020-objective-c-helper"

module ObjectiveC
  class RuntimeObject
    extend FFI::DataConverter

    attr_reader :pointer

    def initialize(pointer)
      @pointer = pointer
    end

    class << self
      def native_type
        FFI::Type::POINTER
      end

      def from_native(value, _)
        self.new(value) unless value.null?
      end

      def to_native(value, _)
        case value
        when self then value.pointer
        when nil then FFI::Pointer::NULL
        else
          raise TypeError, "expected a kind of #{self.name}, was #{value.class}"
        end
      end

      private def function(native_name, arguments, return_type)
        Helper.function(Helper.find_function(native_name), arguments, return_type)
      end

      def singleton_function(name, native_name, arguments, return_type)
        f = function(native_name, arguments, return_type)

        define_singleton_method(name, &f)
      end

      def instance_function(name, native_name, arguments, return_type)
        f = function(native_name, [self] + arguments, return_type)

        define_method(name) { |*args| f.call(self, *args) }
      end
    end
  end

  class Object < RuntimeObject
  end

  class Class < Object
  end

  class Selector < RuntimeObject
  end
end
