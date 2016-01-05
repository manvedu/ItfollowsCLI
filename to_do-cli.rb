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
    
    def uri(name)
      URI.parse("#{host}/#{name}.json")
    end
    def build_http(name)
      uri = uri(name)
      Net::HTTP.new(uri.host, uri.port)
    end
    def get(name)
      uri = uri(name)
      build_http(name).get(uri.path, headers)
    end
  
    def post(name, payload)
      uri = uri(name)
      build_http(name).post(uri.path, payload.to_json, headers)
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
  def login
  end
    
  desc "",""
  def list(name)
    response = get(name)
    lines = JSON.parse(response.body)
    puts lines.inspect
  end

  desc "", ""
    method_option :dfn, required: true
  def new(name)
    payload = {'line_entry' => {"data" => {"dfn" => options[:dfn]}}}
    response = post(name, payload)
    line = JSON.parse(response.body)
    puts "#{line["id"]} #{line["user_id"]} #{line["name"]}"
  end

  desc "", ""
  def show(name)
  end
end

ItfollowsCLI.start(ARGV)
