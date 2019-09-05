require "./12-tick-tick-ticka-tick-take-your-time.rb"

module ObjectiveC
  class Method < Demo::ConvertedObject
    def self.from_native(value, _)
      super if value != 0
    end

    def self.to_native(value, _)
      value == 0 ? nil : super
    end

    def arguments
      ObjectiveC.method_getNumberOfArguments(self).times.map { |i| ObjectiveC.method_copyArgumentType(self, i) }
    end

    def return_type
      ObjectiveC.method_copyReturnType(self)
    end

    def to_callback
      Function.new(self.return_type, self.arguments, ObjectiveC.method_getImplementation(self)).implementation(blocking: true)
    end
  end
end

if __FILE__ == $0
  string = "I work real hard to collect my cash!\n"

  ObjectiveC::Class.find("NSFileHandle").fileHandleWithStandardOutput.writeData(NSData.dataWithBytes(string, length: string.bytesize))
end
