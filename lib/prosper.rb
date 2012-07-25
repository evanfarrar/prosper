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
    loans = loans_rec(loans, 100, 1_000_000)
    loans.flatten.compact.uniq {|l| l["Key"] }
  end

private
  def self.soap
    @@soap ||= LolSoap::Client.new(open('https://services.prosper.com/ProsperAPI/ProsperAPI.asmx?WSDL').read)
  end

  def self.loans_rec(loans, min, max)
    newloans = getloans_amount(min,max)
    halfway = max - ((max - min) / 2)
    if newloans.length == 2000 && halfway!=max
      halfway = max - ((max - min) / 2)
      loans = loans_rec(loans, min, halfway)+loans_rec([], halfway, max)
    elsif halfway==max
      loans+loans_rec_year([], max, 2005, Time.now.year+1)
    else
      loans+newloans
    end
  end

  def self.loans_rec_year(loans, amount, min, max)
    newloans = getloans_year(amount, min,max)
    halfway = max - ((max - min) / 2)
    if newloans.length == 2000 && halfway!=max
      halfway = max - ((max - min) / 2)
      loans = loans_rec_year(loans, amount, min, halfway)+loans_rec_year([], amount, halfway, max)
    else
      warn("too many for #{amount} in #{max}") if halfway==max
      loans+newloans
    end

  end

  def self.getloans_year(amount, min, max)
    getloans("AmountBorrowed = #{amount} AND OriginationDate > '#{min}-1-1T00:00:00' AND OriginationDate <= '#{max}-1-1T00:00:00'", true)
  end

  def self.getloans_amount(min, max)
    getloans("AmountBorrowed > #{min} AND AmountBorrowed <= #{max}")
  end

  def self.getloans(expression, inspec=false)
    request = soap.request("Query")
    request.body do |b|
      b.authentication_token @@login_token
      b.objectType "Loan"
      b.fields "Key,AmountBorrowed,OriginationDate"
      b.conditionExpression expression
    end
    response = HTTParty.post(request.url, :headers => request.headers, :body => request.content)
    result = soap.response(request, response.body).body_hash
    #puts result if inspec
    loans = result["QueryResult"]["ProsperObjects"]["ProsperObject"]
    #warn("Loans missed! too many #{expression}") if loans && loans.length == 2000 && expression =~ /OriginationDate/
    loans||[]
  end
end
