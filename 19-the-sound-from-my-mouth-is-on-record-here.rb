$LOADED_FEATURES << "#{__dir__}/#{__FILE__}" if __FILE__ == $0

require "./06-we-do-what-we-want-and-we-do-it-with-pride.rb"
require "./16-no-limits-allowed-cause-theres-much-crowd.rb"
require "./17-microphone-check-as-i-choose-my-rhyme.rb"
require "./18-im-playing-on-the-road-ive-got-no-fear.rb"

module Java
  class VMInitArguments < FFI::Struct
    layout :version, :int, :n_options, :int, :options, :pointer, :ignore_unrecognized, :uint8_t
  end
  
  class VMOption < FFI::Struct
    layout :option_string, :pointer, :extra_info, :pointer
  end

  extend FFI::Library

  ffi_lib "/Library/Java/JavaVirtualMachines/jdk1.8.0_181.jdk/Contents/Home/jre/lib/server/libjvm.dylib"

  attach_function :JNI_CreateJavaVM, [:pointer, :pointer, :pointer], :int

  options = VMOption.new(FFI::MemoryPointer.new(VMOption, 1, true))
  options[:option_string] = FFI::MemoryPointer.from_string("-Xcheck:jni")
  args = VMInitArguments.new(FFI::MemoryPointer.new(VMInitArguments, 1, true))
  args[:version] = 0x00010008 # JNI_VERSION_1_8
  args[:n_options] = 1
  args[:options] = options

  vm, env = FFI::MemoryPointer.new(:pointer), FFI::MemoryPointer.new(:pointer)

  raise "lol, no JVM for us" unless JNI_CreateJavaVM(vm, env, args) == 0

  # We don't need a stinky VM
  Thread.current[:env] = Environment.new(env.read_pointer)
  Thread.current[:vtable] = Functions.new(env.read_pointer.read_pointer)

  def self.vtable
    Thread.current[:vtable]
  end
end

System = Java::Class.find("java/lang/System") # if __FILE__ == $0

puts "#{Java.string("The sound from my mouth is the rap you hear")}" if __FILE__ == $0