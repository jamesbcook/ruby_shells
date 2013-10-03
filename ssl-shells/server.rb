#!/usr/bin/env ruby
require 'socket'
require 'openssl'
def ssl_setup
  tcp_server = TCPServer.new('localhost',8080)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.key = OpenSSL::PKey::RSA.new 2048
  ctx.cert = OpenSSL::X509::Certificate.new
  ctx.cert.subject = OpenSSL::X509::Name.new [['CN', 'localhost']]
  ctx.cert.issuer = ctx.cert.subject
  ctx.cert.public_key = ctx.key
  ctx.cert.not_before = Time.now
  ctx.cert.not_after = Time.now + 60 * 60 * 24
  ctx.cert.sign ctx.key, OpenSSL::Digest::SHA1.new
  server = OpenSSL::SSL::SSLServer.new tcp_server, ctx
  client = server.accept
  return client
end
def start_loop(client)
  loop {
    command = [(print ("shell> ")), $stdin.gets.rstrip][1]
    start_loop(client) if command == ''
    client.print("#{command}\n")
    exit if command == 'exit'
    results = client.gets
    puts results.split('\n')
  }
end
begin
  client = ssl_setup
  start_loop(client)
end
