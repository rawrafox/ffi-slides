require "ffi"

module C
  extend FFI::Library

  ffi_lib "c"

  attach_function :write, [:int, :pointer, :size_t], :int
end

m = "No, no, no, no, no, no, no, no, no, no, no, no there's no limit!\n\0"

C.write($stdout.to_i, FFI::MemoryPointer.from_string(m), m.bytesize)
C.write($stdout.to_i, FFI::MemoryPointer.from_string(m), m.bytesize)
