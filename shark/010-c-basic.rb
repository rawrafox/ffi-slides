require "ffi"

# First we can do this the low-level way, using the ffi gem
# just like one would use libffi.

# These aren't really important unless you really know linking
options = FFI::DynamicLibrary::RTLD_LAZY | FFI::DynamicLibrary::RTLD_LOCAL

# Open the current process, instead of a dynamic library
process = FFI::DynamicLibrary.open(nil, options)

# `write` writes to a file descriptor
write = FFI::Function.new(:size_t, [:int, :pointer, :size_t], process.find_function("write"))

string = "Standard-issue Swedish Shark says 'Haj Danmark!'\n"

# Then we can call it like we could with a normal `Proc`
# (we'll show how to convert it to a proc later)
write.call($stdout.to_i, string, string.bytesize)
