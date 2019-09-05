require "./05-no-no-limits-wont-give-up-the-fight.rb"

module Demo
  class ConvertedObject
    attr_reader :raw

    def initialize(value)
      @raw = value
    end

    def self.from_native(value, _)
      self.new(value)
    end

    def self.to_native(value, _)
      return value.raw if value.is_a?(self)
      
      raise ArgumentError, "#{value} is not a #{self}"
    end

    def self.to_ffi_type
      FFI::Type::Mapped.new(self)
    end

    def to_ffi_type
      self.class.to_ffi_type
    end

    def ==(other)
      other.is_a?(ConvertedObject) && self.raw == other.raw
    end
  end
end

module Ruby
  class ID < Demo::ConvertedObject
    def self.to_native(value, _)
      return Ruby.rb_sym2id(value).raw if value.is_a?(Symbol)

      super
    end
  end

  attach_function :rb_sym2id, [Value], ID
  attach_function :rb_funcall, [Value, ID, :int, :varargs], Value

  def self.funcall(this, op, *args)
    Ruby.rb_funcall(this, op, args.count, *args.flat_map { |a| [Ruby::Value, a] })
  end
end

class Object
  def f
    "We do what we want and we do it with pride!"
  end
end

Ruby.funcall($stderr, :puts, Ruby.funcall(Object.new, :f)) if __FILE__ == $0
