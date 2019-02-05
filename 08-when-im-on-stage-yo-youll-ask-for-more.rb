require "./12-tick-tick-ticka-tick-take-your-time.rb"

module ObjectiveC
  class Class < Object
    def self.allocate_pair(superclass, name, extra)
      ObjectiveC.objc_allocateClassPair(superclass, name, extra)
    end

    def self.find(name)
      ObjectiveC.objc_getClass(name)
    end

    def add_method(selector, return_type, *arguments, &block)
      f = Function.new(return_type, ["@", ":"] + arguments, block)

      ObjectiveC.class_addMethod(self, selector, f.implementation, f.objc_type)
    end

    def register
      ObjectiveC.objc_registerClassPair(self); self
    end

    def objc_method(selector)
      self.objc_class_method(selector)
    end

    def objc_class_method(selector)
      ObjectiveC.class_getClassMethod(self, selector)
    end

    def objc_instance_method(selector)
      ObjectiveC.class_getInstanceMethod(self, selector)
    end
  end
end

if __FILE__ == $0
  TwoUnlimited = ObjectiveC::Class.allocate_pair(ObjectiveC::Class.find("NSObject"), "TwoUnlimited", 0)

  TwoUnlimited.add_method("sing!", "v") do |_, _|
    puts "When I'm on stage, yo. You'll ask for more!"
  end

  TwoUnlimited.alloc.init.sing!
end
