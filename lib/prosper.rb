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

  def self.loans
    loans = []
    (100..20_000).to_a.each_slice(1000).map{|a|[a.first,a.last]}.each do |min, max|
      loans << getloans(min, max)
    end
    puts "< 20_000 #{loans.flatten.length}"
    (20_000..100_000).to_a.each_slice(1_000).map{|a|[a.first,a.last]}.each do |min, max|
      loans << getloans(min, max)
    end
    puts "< 100_000 #{loans.flatten.length}"
    loans << getloans(100_000, 1_000_000)
    puts "< 1_000_000 #{loans.flatten.length}"
    loans.flatten
  end

private
  def self.soap
    @@soap ||= LolSoap::Client.new(open('https://services.prosper.com/ProsperAPI/ProsperAPI.asmx?WSDL').read)
  end

  def self.getloans(min,max)
    request = soap.request("Query")
    request.body do |b|
      b.authentication_token @@login_token
      b.objectType "Loan"
      b.fields "Key,AmountBorrowed,OriginationDate"
      b.conditionExpression "AmountBorrowed >= #{min} AND AmountBorrowed <= #{max}"
    end
    response = HTTParty.post(request.url, :headers => request.headers, :body => request.content)
    result = soap.response(request, response.body).body_hash
    loans = result["QueryResult"]["ProsperObjects"]["ProsperObject"]
    warn("Loans missed! too many #{min}..#{max}") if loans && loans.length == 2000
    loans
  end
end
