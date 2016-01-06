#!/Users/manvedu/.rvm/rubies/ruby-2.2.3/bin/ruby

require 'net/http'
require 'json'
require 'uri'
require "thor"

class ItfollowsCLI < Thor
  no_commands do
    def touch(data)
      f = File.open("algo", "w")
      f.puts(data)
      f.close
    end
    def output(file_name)
      contents = File.read(file_name)
      JSON.parse(contents)
    end

    def login_headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    def headers(file_name)
      {
        'X-User-Token' => token(file_name),
        'X-User-Email' => email(file_name),
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end
    
    def uri_for_show(name, id)
      URI.parse("#{host}/#{name}/#{id}/edit.json")
    end
    def uri(name)
      URI.parse("#{host}/#{name}.json")
    end
    def build_http(name, uri)
      Net::HTTP.new(uri.host, uri.port)
    end
    def get(name, uri, file_name)
      build_http(name, uri).get(uri.path, headers(file_name))
    end
  
    def post(name, payload, uri, file_name)
      build_http(name, uri).post(uri.path, payload.to_json, headers(file_name))
    end
  
    def host
      'http://localhost:3000'
    end
  
    def email(file_name)
      output(file_name).values.first
    end
    def token(file_name)
      output(file_name).values.last
    end
  end

  desc "itfollows LOGIN", "Login into itfollows"
    method_option :email, required: true
    method_option :password, required: true
  def login
    uri = URI.parse("#{host}/users/sign_in.json")
    http = Net::HTTP.new(uri.host, uri.port)
    payload = {"user" => {"email" => options[:email], "password" => options[:password]}} 
    response = http.post(uri.path, payload.to_json, login_headers)
    lines = JSON.parse(response.body)
    touch(response.body)
    puts lines
  end
    
  desc "",""
  def list(name)
    uri = uri(name)
    file_name = "algo"
    response = get(name, uri, file_name)
    lines = JSON.parse(response.body)
    puts lines.inspect
  end

  desc "", ""
    method_option :dfn, required: true
  def new(name)
#ojo porque aca solo esta pensado para un line entry con esa data
    payload = {'line_entry' => {"data" => {"dfn" => options[:dfn]}}}
    uri = uri(name)
    file_name = "algo"
    response = post(name, payload, uri, file_name)
    line = JSON.parse(response.body)
    puts "#{line["id"]} #{line["user_id"]} #{line["name"]}"
  end

  desc "", ""
    method_option :id, required: true
  def show(name)
    uri = uri_for_show(name, options[:id])
    file_name = "algo"
    response = get(name, uri, file_name)
    lines = JSON.parse(response.body)
    puts lines.inspect
  end

end

ItfollowsCLI.start(ARGV)
