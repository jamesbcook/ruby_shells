#!/usr/bin/env ruby
module MainCommands
  def print_error(text)
	  print "\e[31m[-]\e[0m #{text}"
	end
	def print_info(text)
	  print "\e[34m[*]\e[0m #{text}"
	end
	def print_success(text)
		print "\e[32m[+]\e[0m #{text}"
	end
	def print_warning(text)
		print "\e[33m[!]\e[0m #{text}"
	end
	def background
		main_shell()
	end
	def list_sessions(client_hash)
		print "ID\tClient\n"
		client_hash.each {|id,client| print "#{id}\t#{client}\n"}
		main_shell()
	end
	def use_session(client_hash)

	end
	def help()
		print "list_sessions\tlist active sessions\nbackground\tput session in the background\nuse_session\tuse a session\nexit\t\texit program\nhelp\t\tthis page\n"
		main_shell()
	end
	def exit()

	end
end
