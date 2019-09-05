require_relative "023-objective-c-runtime"

module ObjectiveC
  class Object
    def method_missing(op, *args)
      selector, arguments = case args.count
      when 0 then ["#{op}", []]
      when 1 then ["#{op}:", [args[0]]]
      when 2
        if args[1].is_a?(Hash)
          ["#{op}:#{args[1].keys.join(":")}:", [args[0]] + args[1].values]
        else
          return super
        end
      else
        return super
      end

      method = self.objc_method(selector)

      return super unless method

      method.call(self, selector, *arguments)
    end

    def to_s
      self.description.UTF8String
    end

    def inspect
      self.debugDescription.UTF8String
    end
  end
end

NSAutoreleasePool = ObjectiveC::Class.find("NSAutoreleasePool")
NSData = ObjectiveC::Class.find("NSData")
NSString = ObjectiveC::Class.find("NSString")

p NSString.alloc.initWithUTF8String("Standard-issue Swedish Shark says 'This isn't the objectively best way to do this, but it is Objective-C!'") if __FILE__ == $0
