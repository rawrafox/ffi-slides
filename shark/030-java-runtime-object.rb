require "ffi"

module Java
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
    end
  end
end
