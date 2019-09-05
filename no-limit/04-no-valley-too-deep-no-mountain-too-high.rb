require "socket"

server = TCPServer.new(1993)

Thread.new { TCPSocket.new('localhost', 1993).puts("No valley to deep, no mountain too high!") }

client = server.accept
puts client.gets
client.close
