require "prosper/version"
require 'httparty'
require 'lolsoap'
require 'open-uri'

module Prosper
  def self.login(username, password)
    request = soap.request("Login")
    request.body { |b| b.email username; b.password password }
    response = HTTParty.post(request.url, :headers => request.headers, :body => request.content)
    result = soap.response(request, response.body).body_hash
    if result["LoginResult"]["Success"] == "true"
      @@login_token = result["LoginResult"]["Message"]
    end
    result["LoginResult"]["Message"]
  end

private
  def self.soap
    @@soap ||= LolSoap::Client.new(open('https://services.prosper.com/ProsperAPI/ProsperAPI.asmx?WSDL').read)
  end
end
