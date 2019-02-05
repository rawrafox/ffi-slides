MEMORY_SIZE = 1 << 24 if __FILE__ != $0

require "./23-im-making-techno-and-i-am-proud.rb"

module Hypervisor
  def self.allocate(n, &block)
    FFI::AutoPointer.new(Hypervisor.valloc(n), Hypervisor.method(:free), &block)
  end

  def self.create(options = 0)
    Hypervisor.return_t(Hypervisor.hv_vm_create(options))
  end

  def self.map(uva, gpa, size, flags)
    Hypervisor.return_t(Hypervisor.hv_vm_map(uva, gpa, size, flags))
  end

  def self.read_capability(field)
    FFI::MemoryPointer.new(:uint64_t, 1) do |value|
      Hypervisor.return_t(Hypervisor.hv_vmx_read_capability(field, value))

      return value.get_uint64(0)
    end
  end
end

if __FILE__ == $0
  # mov ah, 0x40
  # mov bx, 0x01
  # mov cl, [0x80]
  # mov dx, 0x81
  # int 0x21
  # mov al, 0x00
  # mov ah, 0x4c
  # int 0x21

  dos("\xb4\x40\xbb\x01\x00\x8a\x0e\x80\x00\xba\x81\x00\xcd\x21\xb0\x00\xb4\x4c\xcd\x21", "No valley to deep, no mountain too high!")
end
