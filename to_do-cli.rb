#!/Users/manvedu/.rvm/rubies/ruby-2.2.3/bin/ruby

require 'net/http'
require 'json'
require 'uri'
require "thor"

class ItfollowsCLI < Thor
  no_commands do
    def headers
      {
        'X-User-Token' => token,
        'X-User-Email' => email,
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
    def get(name, uri)
      build_http(name, uri).get(uri.path, headers)
    end
  
    def post(name, payload, uri)
      build_http(name, uri).post(uri.path, payload.to_json, headers)
    end
  
    def host
      'http://localhost:3000'
    end
  
    def email
      'mariavelandia@fluvip.com'
    end
    def token
      '6i6cv3zLL5aKfX1zEhNS'
    end
  end

  desc "itfollows LOGIN", "Login into itfollows"
    method_option :email, required: true
    method_option :password, required: true
  def login
    headers1 = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    uri = URI.parse("#{host}/users/sign_in.json")
    http = Net::HTTP.new(uri.host, uri.port)
    payload = {"user" => {"email" => options[:email], "password" => options[:password]}} 
    response = http.post(uri.path,payload.to_json, headers1)
    lines = JSON.parse(response.body)
    #lines.values[0]
    puts lines
  end
    
  desc "",""
  def list(name)
    uri = uri(name)
    response = get(name, uri)
    lines = JSON.parse(response.body)
    puts lines.inspect
  end

  desc "", ""
    method_option :dfn, required: true
  def new(name)
    payload = {'line_entry' => {"data" => {"dfn" => options[:dfn]}}}
    uri = uri(name)
    response = post(name, payload, uri)
    line = JSON.parse(response.body)
    puts "#{line["id"]} #{line["user_id"]} #{line["name"]}"
  end

  desc "", ""
    method_option :id, required: true
  def show(name)
    uri = uri_for_show(name, options[:id])
    response = get(name, uri)
    lines = JSON.parse(response.body)
    puts lines.inspect
  end
end

ItfollowsCLI.start(ARGV)
