require "./12-tick-tick-ticka-tick-take-your-time.rb"

module ObjectiveC
  class Object < Demo::ConvertedObject
    def self.from_native(value, _)
      super if value != 0
    end

    def self.to_native(value, _)
      value.nil? ? 0 : super
    end

    def objc_class
      ObjectiveC.object_getClass(self)
    end

    def objc_method(selector)
      self.objc_class.objc_instance_method(selector)
    end

    def method_missing(op, *args)
      selector, arguments = case args.count
      when 0 then ["#{op}", []]
      when 1 then ["#{op}:", [args[0]]]
      when 2 then ["#{op}:#{args[1].keys.join(":")}:", [args[0]] + args[1].values]
      else
        raise ArgumentError, "oh noes"
      end

      method = self.objc_method(selector)

      return super unless method

      method.to_callback.call(self, selector, *arguments)
    end

    def to_s
      self.description.UTF8String
    end

    def inspect
      self.debugDescription.UTF8String
    end
  end
end

p NSString.alloc.initWithUTF8String("Hard to the core, I feel the floor!") if __FILE__ == $0
