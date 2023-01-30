require "socket"
require "openssl"
require "base64"

class Client
    def initialize(host, port)
    	
        @socket = TCPSocket.new(host, port)
        @private_key = nil
        @my_public_key = nil
        @his_public_key = nil
        @threads = []
        @established = false
        @exchange_ready = false
        @interlocutor = nil
    end

    def keygen()
        puts "Generating RSA Keypair..."
        key = OpenSSL::PKey::RSA.new(2048)
        @private_key = key
        @my_public_key = key.public_key
        puts "Done!"
    end

    def is_base64?(string)
        begin
          Base64.strict_decode64(string)
          true
        rescue ArgumentError
          false
        end
      end

    def encrypt(str)
        encrypted_message = @his_public_key.public_encrypt(str)
        return Base64.strict_encode64(encrypted_message)
    end

    def decrypt(str)
    	puts "DEBUG -> STARTED DECRYPTING #{str}"
        decrypted_message = @private_key.private_decrypt(Base64.strict_decode64(str))
        return decrypted_message
    end

    def receive()
        @threads << Thread.new {
        
            while line = @socket.gets.chomp

	            if line == "RSA_EXCHANGE_READY"
	            	puts "DEBUG -> EXCHANGE READY"
					@exchange_ready = true
					next
	            end
	            if @exchange_ready
	            	puts "DEBUG -> #{line}"
					@his_public_key = OpenSSL::PKey::RSA.new(Base64.strict_decode64(line))
	            	@established = true
	            	@exchange_ready = false
	            	next
	            end
	            if @established && is_base64?(line)
					puts "( #{@interlocutor} ): #{decrypt(line.chomp)}"
				else
					puts line
	            end
                
                
            end
       }
    end
 
    def send()
        @threads << Thread.new{
            while line = gets.chomp
                if @established
                    encrypted = self.encrypt(line)
                    @socket.puts(encrypted)
                    puts "( me ): #{line}"
                else
                    @socket.puts(line)
                end
            end
            exit!
        }
    end

    def start()
        self.keygen()

        puts("Enter your name:")
        print("> ")
        name = gets.chomp
        puts("Enter your interlocutors name:")
        print("> ")
        @interlocutor = gets.chomp
        @socket.puts(name)
        @socket.puts(@interlocutor)
        @socket.puts(Base64.strict_encode64(@my_public_key.to_pem))

        self.receive()
        self.send()
        @threads.each{|th| th.join}
    end

end


client = Client.new("localhost", 9999)
client.start








