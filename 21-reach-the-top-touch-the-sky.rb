require "./23-im-making-techno-and-i-am-proud.rb"

module Hypervisor
  class VCPU
    def self.cap(cap, ctrl)
      (ctrl | (cap & 0xffffffff)) & (cap >> 32)
    end
    
    def initialize(flags = 0)
      FFI::MemoryPointer.new(:uint, 1) do |vcpu|
        Hypervisor.return_t(Hypervisor.hv_vcpu_create(vcpu, flags))

        @vcpu = vcpu.get_uint(0)
      end

      self.write_vmcs(Hypervisor::VMX_CAP_PINBASED, VCPU.cap(Hypervisor.read_capability(Hypervisor::VMX_CAP_PINBASED), 0))
      self.write_vmcs(Hypervisor::VMX_CAP_PROCBASED, VCPU.cap(Hypervisor.read_capability(Hypervisor::VMX_CAP_PROCBASED), Hypervisor::CPU_BASED_HLT))
      self.write_vmcs(Hypervisor::VMX_CAP_PROCBASED2, VCPU.cap(Hypervisor.read_capability(Hypervisor::VMX_CAP_PROCBASED2), 0))
      self.write_vmcs(Hypervisor::VMX_CAP_ENTRY, VCPU.cap(Hypervisor.read_capability(Hypervisor::VMX_CAP_ENTRY), 0))
      self.write_vmcs(Hypervisor::VMX_CAP_PREEMPTION_TIMER, VCPU.cap(Hypervisor.read_capability(Hypervisor::VMX_CAP_PREEMPTION_TIMER), 0))

      self.write_vmcs(Hypervisor::VMCS_CTRL_EXC_BITMAP, 0xffffffff)
      self.write_vmcs(Hypervisor::VMCS_CTRL_CR0_MASK, 0x60000000)
      self.write_vmcs(Hypervisor::VMCS_CTRL_CR0_SHADOW, 0)
      self.write_vmcs(Hypervisor::VMCS_CTRL_CR4_MASK, 0)
      self.write_vmcs(Hypervisor::VMCS_CTRL_CR4_SHADOW, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_CS, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_CS_LIMIT, 0xffff)
      self.write_vmcs(Hypervisor::VMCS_GUEST_CS_AR, 0x9b)
      self.write_vmcs(Hypervisor::VMCS_GUEST_CS_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_DS, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_DS_LIMIT, 0xffff)
      self.write_vmcs(Hypervisor::VMCS_GUEST_DS_AR, 0x93)
      self.write_vmcs(Hypervisor::VMCS_GUEST_DS_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_ES, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_ES_LIMIT, 0xffff)
      self.write_vmcs(Hypervisor::VMCS_GUEST_ES_AR, 0x93)
      self.write_vmcs(Hypervisor::VMCS_GUEST_ES_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_FS, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_FS_LIMIT, 0xffff)
      self.write_vmcs(Hypervisor::VMCS_GUEST_FS_AR, 0x93)
      self.write_vmcs(Hypervisor::VMCS_GUEST_FS_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_GS, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_GS_LIMIT, 0xffff)
      self.write_vmcs(Hypervisor::VMCS_GUEST_GS_AR, 0x93)
      self.write_vmcs(Hypervisor::VMCS_GUEST_GS_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_SS, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_SS_LIMIT, 0xffff)
      self.write_vmcs(Hypervisor::VMCS_GUEST_SS_AR, 0x93)
      self.write_vmcs(Hypervisor::VMCS_GUEST_SS_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_LDTR, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_LDTR_LIMIT, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_LDTR_AR, 0x10000)
      self.write_vmcs(Hypervisor::VMCS_GUEST_LDTR_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_TR, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_TR_LIMIT, 0)
      self.write_vmcs(Hypervisor::VMCS_GUEST_TR_AR, 0x83)
      self.write_vmcs(Hypervisor::VMCS_GUEST_TR_BASE, 0)

      self.write_vmcs(Hypervisor::VMCS_GUEST_CR0, 0x20)
      self.write_vmcs(Hypervisor::VMCS_GUEST_CR4, 0x2000)

      self.write_register(Hypervisor::X86_RIP, 0x100)
      self.write_register(Hypervisor::X86_RFLAGS, 0x2)
      self.write_register(Hypervisor::X86_RSP, 0x0)
    end

    def run
      Hypervisor.return_t(Hypervisor.hv_vcpu_run(@vcpu))
    end

    def read_register(register)
      FFI::MemoryPointer.new(:uint64_t, 1) do |value|
        Hypervisor.return_t(Hypervisor.hv_vcpu_read_register(@vcpu, register, value))

        return value.read_uint64
      end
    end

    def write_register(register, value)
      Hypervisor.return_t(Hypervisor.hv_vcpu_write_register(@vcpu, register, value))
    end

    def read_vmcs(field)
      FFI::MemoryPointer.new(:uint64_t, 1) do |value|
        Hypervisor.return_t(Hypervisor.hv_vmx_vcpu_read_vmcs(@vcpu, field, value))

        return value.read_uint64
      end
    end

    def write_vmcs(field, value)
      Hypervisor.return_t(Hypervisor.hv_vmx_vcpu_write_vmcs(@vcpu, field, value))
    end

    # Helpers

    [[:a, 2], [:b, 5], [:c, 3], [:d, 4]].each do |register, const|
      define_method("#{register}x") do
        read_register(const) & 0xffff
      end

      define_method("#{register}x=") do |value|
        write_register(const, value & 0xffff)
      end

      define_method("#{register}l") do
        read_register(const) & 0xff
      end

      define_method("#{register}l=") do |value|
        old = read_register(const) & 0xff00

        write_register(const, old | (value & 0xff))
      end

      define_method("#{register}h") do
        (read_register(const) & 0xff00) >> 8
      end

      define_method("#{register}h=") do |value|
        old = read_register(const) & 0xff

        write_register(const, old | ((value & 0xff) << 8))
      end
    end

    def ds
      read_register(20)
    end

    def flags
      read_register(Hypervisor::X86_RFLAGS)
    end

    def flags=(value)
      write_register(Hypervisor::X86_RFLAGS, value)
    end
  end
end

if __FILE__ == $0
  msg = "Reach the top, touch the sky"
  # mov ah, 0x40
  # mov bx, 0x01
  # mov cl, 28
  # mov dx, 0x112
  # int 0x21
  # mov al, 0x00
  # mov ah, 0x4c
  # int 0x21

  dos("\xb4\x40\xbb\x01\x00\xb1\x1c\xba\x12\x01\xcd\x21\xb0\x00\xb4\x4c\xcd\x21" + msg)
end
