require 'spec_helper'

describe Prosper do
  it "should be" do
    Prosper.should be
  end
  describe "login" do
    it "should raise when incorrect" do
      res = Prosper.login('mp2p@prosper.int', 'Password23')
      res.should =~ /Incorrect login information/
    end

    it "should return a token when correct" do
      raise "set your username and PW as ENV variables to run the tests" unless ENV['PROSPERUSERNAME']
      res = Prosper.login(ENV['PROSPERUSERNAME'], ENV['PROSPERPASSWORD'])
      res.length.should == 40
    end

  end

  describe "loans" do
    it "should "
    it "should return all loans" do
      Prosper.login(ENV['PROSPERUSERNAME'], ENV['PROSPERPASSWORD'])
      loans = Prosper.loans
      puts loans.length
      loans.length.should be > 100
      loans.length.should be > 2000 #Pagination!
    end
  end
end
