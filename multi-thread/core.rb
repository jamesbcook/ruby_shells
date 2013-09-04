#!/usr/bin/env ruby
require 'openssl'
require 'base64'
require 'readline'
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
  def background()
    main_shell()
  end
  def list_sessions(client_hash)
    print "ID\tClient\n"
    client_hash.each {|id,client| print "#{id}\t#{client}\n"}
    main_shell()
  end
  def use_session(client)
    command_client(client)
  end
  def help()
    print "\nlist_sessions\tlist active sessions\nbackground\tput session in the background\nuse_session\tuse a session\nexit\t\texit program\nhelp\t\tthis page\n\n"
    main_shell()
  end
  def exit()

  end
  def client_status(client_array,client_hash)
    loop {
      client_array.each do |client|
        array_index = client_array.index(client)
        next if client == nil
        if client.closed?
          print_info("#{client_hash[:"#{array_index}"]} left\n")
          client_hash.delete(:"#{array_index}")
          client_array.delete_at(array_index)
          client_array.insert(array_index,nil)
        end
      end
      sleep(1)
    }
    rescue => e
      puts e
  end
  @aes = OpenSSL::Cipher.new("AES-256-CFB")
  @key = 'abcdefghijklmnopqrstuvwxyz123456'
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
  LIST = ['background','list_sessions','use_session','help','exit'].sort
  comp = proc { |s| LIST.grep(/^#{Regexp.escape(s)}/) }
  Readline.completion_proc = comp
end
