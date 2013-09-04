require 'socket'
def start_loop(client)
  loop {
    command = [(print ("shell> ")), $stdin.gets.rstrip][1]
    start_loop(client) if command == ''
    client.print("#{command}")
    exit if command == 'exit'		
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
  server = TCPServer.open(443)
  client = server.accept
  start_loop(client)
end
