require "./23-im-making-techno-and-i-am-proud.rb"

unless __FILE__ == $0
  module Hypervisor
    X86_RIP       = 0
    X86_RFLAGS    = 1
    X86_RSP       = 8

    VMX_CAP_PINBASED = 0
    VMX_CAP_PROCBASED = 1
    VMX_CAP_PROCBASED2 = 2
    VMX_CAP_ENTRY = 3
    VMX_CAP_EXIT = 4
    VMX_CAP_PREEMPTION_TIMER = 32

    VMCS_GUEST_ES = 0x00000800
    VMCS_GUEST_CS = 0x00000802
    VMCS_GUEST_SS = 0x00000804
    VMCS_GUEST_DS = 0x00000806
    VMCS_GUEST_FS = 0x00000808
    VMCS_GUEST_GS = 0x0000080a
    VMCS_GUEST_LDTR = 0x0000080c
    VMCS_GUEST_TR = 0x0000080e

    VMCS_CTRL_EXC_BITMAP = 0x00004004
    VMCS_RO_INSTR_ERROR = 0x00004400
    VMCS_RO_EXIT_REASON = 0x00004402
    VMCS_RO_IDT_VECTOR_INFO = 0x00004408
    VMCS_GUEST_ES_LIMIT = 0x00004800
    VMCS_GUEST_CS_LIMIT = 0x00004802
    VMCS_GUEST_SS_LIMIT = 0x00004804
    VMCS_GUEST_DS_LIMIT = 0x00004806
    VMCS_GUEST_FS_LIMIT = 0x00004808
    VMCS_GUEST_GS_LIMIT = 0x0000480a
    VMCS_GUEST_LDTR_LIMIT = 0x0000480c
    VMCS_GUEST_TR_LIMIT = 0x0000480e
    VMCS_GUEST_GDTR_LIMIT = 0x00004810
    VMCS_GUEST_IDTR_LIMIT = 0x00004812
    VMCS_GUEST_ES_AR = 0x00004814
    VMCS_GUEST_CS_AR = 0x00004816
    VMCS_GUEST_SS_AR = 0x00004818
    VMCS_GUEST_DS_AR = 0x0000481a
    VMCS_GUEST_FS_AR = 0x0000481c
    VMCS_GUEST_GS_AR = 0x0000481e
    VMCS_GUEST_LDTR_AR = 0x00004820
    VMCS_GUEST_TR_AR = 0x00004822
    VMCS_CTRL_CR0_MASK = 0x00006000
    VMCS_CTRL_CR4_MASK = 0x00006002
    VMCS_CTRL_CR0_SHADOW = 0x00006004
    VMCS_CTRL_CR4_SHADOW = 0x00006006
    VMCS_CTRL_CR3_VALUE0 = 0x00006008
    VMCS_CTRL_CR3_VALUE1 = 0x0000600a
    VMCS_CTRL_CR3_VALUE2 = 0x0000600c
    VMCS_CTRL_CR3_VALUE3 = 0x0000600e
    VMCS_RO_EXIT_QUALIFIC = 0x00006400
    VMCS_GUEST_CR0 = 0x00006800
    VMCS_GUEST_CR4 = 0x00006804
    VMCS_GUEST_ES_BASE = 0x00006806
    VMCS_GUEST_CS_BASE = 0x00006808
    VMCS_GUEST_SS_BASE = 0x0000680a
    VMCS_GUEST_DS_BASE = 0x0000680c
    VMCS_GUEST_FS_BASE = 0x0000680e
    VMCS_GUEST_GS_BASE = 0x00006810
    VMCS_GUEST_LDTR_BASE = 0x00006812
    VMCS_GUEST_TR_BASE = 0x00006814
    VMCS_GUEST_GDTR_BASE = 0x00006816
    VMCS_GUEST_IDTR_BASE = 0x00006818

    CPU_BASED_HLT                       = 1 << 7

    VMX_REASON_EXC_NMI = 0
    VMX_REASON_IRQ = 1
    VMX_REASON_HLT = 12
    VMX_REASON_EPT_VIOLATION = 48
  end
end

module Hypervisor
  extend FFI::Library

  ffi_lib "/System/Library/Frameworks/Hypervisor.framework/Hypervisor"

  attach_function :valloc, [:size_t], :pointer
  attach_function :free, [:pointer], :void

  attach_function :hv_vm_create, [:uint64_t], :uint
  attach_function :hv_vm_map, [:pointer, :uint64_t, :size_t, :uint64_t], :uint

  attach_function :hv_vcpu_create, [:pointer, :uint64_t], :uint
  attach_function :hv_vcpu_read_register, [:uint, :int, :pointer], :uint
  attach_function :hv_vcpu_write_register, [:uint, :int, :uint64_t], :uint
  attach_function :hv_vcpu_run, [:uint], :uint, blocking: true

  attach_function :hv_vmx_vcpu_read_vmcs, [:uint, :uint32_t, :pointer], :uint
  attach_function :hv_vmx_vcpu_write_vmcs, [:uint, :uint32_t, :uint64_t], :uint
  attach_function :hv_vmx_read_capability, [:int, :pointer], :uint

  def self.return_t(result)
    unless result == 0
      case result
      when 0
        return
      when 0xfae94001
        raise "Error"
      when 0xfae94002
        raise "Busy"
      when 0xfae94003
        raise "Bad Argument"
      when 0xfae94005
        raise "No Resources"
      when 0xfae94006
        raise "No Device"
      when 0xfae9400f
        raise "Hypervisor.framework is not supported on your computer"
      else
        raise "Something went wrong #{result}"
      end
    end
  end
end

if __FILE__ == $0
  io = StringIO.new
  io.puts "They tried to diss me, 'cause I sell out"
  io.rewind

  # mov ah, 0x3f
  # mov bx, 0x00
  # mov cx, 40
  # mov dx, 0x300
  # int 0x21
  # mov al, 0x00
  # mov ah, 0x4c
  # int 0x21

  _, memory = dos("\xb4\x3f\xbb\x00\x00\xb9\x28\x00\xba\x00\x03\xcd\x21\xb0\x00\xb4\x4c\xcd\x21", fds: [io])

  puts memory.get_bytes(0x300, 40)
end

