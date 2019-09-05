require "socket"

# The most common way otherwise is to put some sort of network
# in the middle, these days we usually use HTTP but you
# can of course do plain TCP or some other protocol you like.
server = TCPServer.new(1337)

Thread.new { TCPSocket.new("localhost", 1337).puts("Standard-issue Swedish Shark says 'The network is an easy way to talk between languages!'") }

client = server.accept
puts client.gets
client.close
