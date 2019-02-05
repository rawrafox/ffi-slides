require "ffi"

module Demo
  class ConvertedObject
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::UINT64
    end
  end
end

module Ruby
  extend FFI::Library

  ffi_lib FFI::CURRENT_PROCESS

  class Value < Demo::ConvertedObject
    def self.to_native(value, _)
      id = value.object_id

      if !value || id & 0x3 != 0
        id
      else
        ptr = id << 1

        symid, x = ptr.divmod(40)

        x == 0x10 ? (symid << 8) + 0xC : ptr
      end
    end

    def self.from_native(value, _)
      if value == 0x0
        false
      elsif value == 0x8
        nil
      elsif value & 0xFF == 0xC
        ObjectSpace._id2ref((value >> 8) * 20 + 0x8)
      elsif value & 0x3 != 0
        ObjectSpace._id2ref(value)
      else
        ObjectSpace._id2ref(value >> 1)
      end
    end
  end

  attach_function :rb_io_write, [Value, Value], Value
end

Ruby.rb_io_write($stdout, "No no limits, won't give up the fight!\n") if __FILE__ == $0
