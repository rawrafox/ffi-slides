require "./12-tick-tick-ticka-tick-take-your-time.rb"

module ObjectiveC
  class Function
    TYPE_MAP = {
      "@" => ObjectiveC::Object.to_ffi_type,
      ":" => ObjectiveC::Selector.to_ffi_type,
      "*" => :string,
      "c" => :char,
      "v" => :void,
      "q" => :long_long,
      "Q" => :ulong_long
    } unless __FILE__ == $0

    TYPE_MAP.default_proc = lambda do |hash, key|
      case key
      when /\Ar/ then return hash[key[1 .. -1]]
      when /\A\^/ then return :pointer
      when /\A\{(\w+)=/ then return Kernel.const_get($1).by_value
      end

      raise KeyError, "could not find type #{key}"
    end

    def initialize(return_type, arguments, implementation)
      @return_type = return_type
      @arguments = arguments
      @implementation = implementation
    end
    
    def objc_type
      ([@return_type] + @arguments).join("")
    end
    
    def implementation(**options)
      FFI::Function.new(TYPE_MAP[@return_type], @arguments.map { |a| TYPE_MAP[a] }, @implementation, **options)
    end
  end
end

if __FILE__ == $0
  TwoUnlimited = ObjectiveC::Class.allocate_pair(ObjectiveC::Class.find("NSObject"), "TwoUnlimited", 0)

  TwoUnlimited.add_method("sing:", "v", "*") do |_, _, string|
    puts string
  end

  TwoUnlimited.alloc.init.sing("I'm on the ass, I know the last!") if __FILE__ == $0
end
