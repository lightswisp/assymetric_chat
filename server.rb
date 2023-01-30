require "socket"
require "base64"


server = TCPServer.new(9999)
connections = {}
puts "Server is listening on 9999"

loop {
begin
		Thread.start(server.accept) do |connection|
			begin
				puts "Connection from: #{connection.peeraddr[2]}"
				name = connection.gets.chomp
				interlocutor = connection.gets.chomp
				public_key = connection.gets.chomp
				connections[name] = { 
					"connection" => connection, 
					"public_key" => public_key,
					"interlocutor" => interlocutor
				}
				
				connection.print "Welcome #{name}!\n"

				if connections.has_key?(interlocutor)
					connection.puts "RSA_EXCHANGE_READY"
					connections[interlocutor]["connection"].puts "RSA_EXCHANGE_READY"
					connection.puts(connections[interlocutor]["public_key"])
					connections[interlocutor]["connection"].puts(public_key)


					connection.puts "Successfully joined the conversation and the RSA public keys exchange is done..."
				 	connections[interlocutor]["connection"].puts("#{name} has joined and RSA public keys exchange is done...")
				else
				 	connection.puts("Waiting for another person to join...")
				end

				while s = connection.gets.chomp
					#break if s.chomp.nil?
					#s = s.chomp
										
					if s == "/disconnect"
						break
					elsif s == "/debug"
						p connections
					end
					puts "[ LOGS ] (#{connection.peeraddr[2]}) #{s}"
					if connections.has_key?(interlocutor)
						connections[interlocutor]["connection"].puts(s)
					end
				end
			
			rescue
				puts "[1] Client disconnected unexpectedly!"
			ensure
				puts "[2] Server deleted the client and closed the connection..."
				connections.delete(name)
				connection.close
			end

		end
	rescue
		puts "asdasdasdasdas"
	end
}
