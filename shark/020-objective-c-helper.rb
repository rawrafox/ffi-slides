require "ffi"

module ObjectiveC
  module Helper
    # Here we load the library globally instead since
    # other libraries will need the objc runtime as well
    options = FFI::DynamicLibrary::RTLD_LAZY |
              FFI::DynamicLibrary::RTLD_GLOBAL

    # Look up the name of the library
    name = FFI.map_library_name("objc")

    OBJC = FFI::DynamicLibrary.open(name, options)

    def self.function(function, arg_types, return_type)
      return_type = FFI.find_type(return_type)
      arg_types = arg_types.map { |e| FFI.find_type(e) }

      FFI::Function.new(return_type, arg_types, function).method(:call)
    end

    def self.find_function(name)
      Helper::OBJC.find_function(name)
    end
  end
end