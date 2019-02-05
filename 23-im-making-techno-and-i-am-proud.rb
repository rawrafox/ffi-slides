require "ffi"

require "./22-they-tried-to-diss-me-cause-i-sell-out.rb"
require "./20-no-valley-too-deep-no-mountain-too-high.rb"
require "./21-reach-the-top-touch-the-sky.rb"

class DOSKernel
  class Stop < StandardError
    attr_reader :return_value

    def initialize(return_value)
      @return_value = return_value

      super("Exiting DOS")
    end
  end

  def initialize(memory, argv, fds)
    @memory = memory
    @argv = argv
    @dta = 0

    @fds = fds

    @memory.put_bytes(0x00, [0xcd, 0x20].pack("c*"))
    @memory.put_bytes(0x50, [0xcd, 0x21, 0xcb].pack("c*"))
    @memory.put_bytes(0x5C, [0x01, 0x20].pack("c*"))

    argv = argv.map { |x| " #{x}" }.join('')

    @memory.put_bytes(0x80, [argv.bytesize, argv, 0x0d].pack("cA*c"))
  end

  def dispatch(cpu, int)
    case int
    when 0x21
      interrupt_0x21(cpu)
    else
      raise "Unknown interrupt: #{int}"
    end
  end

  private def interrupt_0x21(cpu)
    case cpu.ah
    when 0x1a # set dta
      @dta = cpu.dx
    when 0x30 # version
      cpu.write_register(Hypervisor::X86_RAX, 0x0700)
    when 0x3d # open
      # TODO: Don't ignore OFLAG
      @fds << File.open(read_string(cpu.ds, cpu.dx))

      cpu.ax = @fds.count - 1
      cpu.cf &= ~1
    when 0x3f # read
      fd = @fds.fetch(cpu.bx)
      data = fd.read(cpu.cx)

      if data
        write_segment(cpu.ds, cpu.dx, data)

        cpu.ax = data.bytesize
        cpu.flags &= ~1
      else
        cpu.ax = 0
        cpu.flags |= 1
      end
    when 0x40 # write
      fd = @fds.fetch(cpu.bx)

      cpu.ax = fd.write(read_segment(cpu.ds, cpu.dx, cpu.cx))
      cpu.flags &= ~1
    when 0x42 # lseek
      fd = @fds.fetch(cpu.bx)

      fd.seek(cpu.cx << 16 | cpu.dx, cpu.al)
    when 0x4c # exit
      raise Stop.new(cpu.al)
    else
      raise "Unsupported: int 0x21 / #{cpu.ah.to_s(16)}"
    end
  end

  def read_segment(s, x, length)
    @memory.get_bytes((s << 4) + x, length)
  end

  def read_string(s, x)
    @memory.get_string((s << 4) + x)
  end

  def write_segment(s, x, value)
    @memory.put_bytes((s << 4) + x, value)
  end
end

def dos(image, *args, fds: [$stdin, $stdout, $stderr])
  Hypervisor.create

  memory = Hypervisor.allocate(MEMORY_SIZE)
  memory.put_bytes(0x100, image)
  kernel = DOSKernel.new(memory, args, fds)
  Hypervisor.map(memory, 0, MEMORY_SIZE, 0x7)
  
  cpu = Hypervisor::VCPU.new

  return_value = -1

  loop do
    cpu.run

    case cpu.read_vmcs(Hypervisor::VMCS_RO_EXIT_REASON)
    when Hypervisor::VMX_REASON_EPT_VIOLATION, Hypervisor::VMX_REASON_IRQ
      next
    when Hypervisor::VMX_REASON_HLT
      break
    when Hypervisor::VMX_REASON_EXC_NMI
      n = cpu.read_vmcs(Hypervisor::VMCS_RO_IDT_VECTOR_INFO) & 0xff

      begin
        kernel.dispatch(cpu, n)
        cpu.write_register(Hypervisor::X86_RIP, cpu.read_register(Hypervisor::X86_RIP) + 2)
      rescue DOSKernel::Stop => e
        return_value = e.return_value
        break
      end
    else
      $stderr.puts("ERROR: #{cpu.read_vmcs(Hypervisor::VMCS_RO_EXIT_REASON)}")
      break
    end
  end

  [return_value, memory]
end

if __FILE__ == $0
  input = StringIO.new
  input.puts "I'm making techno and I am proud!"
  input.rewind

  output = StringIO.new

  # mov ah, 0x3f
  # mov bx, 0x00
  # mov cx, 33
  # mov dx, 0x300
  # int 0x21
  # mov ah, 0x40
  # mov bx, 0x01
  # mov cx, 33
  # mov dx, 0x300
  # int 0x21
  # mov al, 0x00
  # mov ah, 0x4c
  # int 0x21

  _, memory = dos("\xb4\x3f\xbb\x00\x00\xb9\x21\x00\xba\x00\x03\xcd\x21\xb4\x40\xbb\x01\x00\xb9\x21\x00\xba\x00\x03\xcd\x21\xb0\x00\xb4\x4c\xcd\x21", fds: [input, output])

  puts output.string
end
