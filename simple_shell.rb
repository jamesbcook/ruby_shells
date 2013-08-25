#!/usr/bin/env ruby
require 'socket'
require 'base64'
begin
  server = TCPServer.open(8080)
  x = 0
  # client = server.accept
  loop{  
    Thread.start(server.accept) do |client|  
      file_name = client.recv(1024)
      out_put = client.gets()
      File.open("#{file_name.strip}#{x}","w") {|f| f.write(Base64.decode64(out_put))}
      x += 1 if file_name == "sys\r\n"
    end
  }
end