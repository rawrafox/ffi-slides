require 'ffi'

# If we want to write a nicer wrapper, we could use the DSL
# included with the ffi gem.

module System
  # This loads the library `libc` and attaches the write
  # function with the right prototype, which you can look
  # up with `man 3 write` or just check the header files.
  module C
    extend FFI::Library

    ffi_lib "c"

    attach_function :write, [:int, :pointer, :size_t], :size_t
  end

  # Then we wrap it in a nicer API
  def self.write(io, value)
    C.write(io.to_i, value, value.bytesize)
  end
end

System.write($stdout, "Standard-issue Swedish Shark says 'Thanks for having me!'\n")
