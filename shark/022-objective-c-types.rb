require_relative "021-objective-c-runtime-object"

# Just some code for converting ObjC type metadata
# to ffi gem compatible metadata, obviously not complete

module ObjectiveC
  module Types
    MAP = {
      "@" => Object,
      ":" => Selector,
      "*" => :string,
      "c" => :char,
      "v" => :void,
      "q" => :long_long,
      "Q" => :ulong_long
    }

    def self.lookup(key)
      MAP.fetch(key) do
        case key
        when /\Ar/ then self.lookup(key[1 .. -1])
        when /\A\^/ then return Types::Pointer
        when /\A\{(\w+)=/ then return Kernel.const_get($1).by_value
        else
          raise KeyError, "could not find type #{key.inspect}"
        end
      end
    end
  end
end
