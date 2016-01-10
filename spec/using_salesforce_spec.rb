require 'spec_helper'
require 'databasedotcom'

describe "Test using salesforce (developer edition)" do
  before do
    account = YAML.load_file('auth_credentials.yml')['salesforce']
    databasedotcom = Databasedotcom::Client.new(client_id: account["customer_key"], client_secret: account["consumer_secret"], verify_mode: OpenSSL::SSL::VERIFY_NONE)
    databasedotcom.authenticate :username => account["username"], :password => "#{account['password']}#{account['security_token']}"
    @client = Seiun::Client.new(databasedotcom: databasedotcom)
    @callback = SeiunSpec::Callbacks::Base
    @object_name = "Campaign"
  end

  describe '#upsert' do
    before do
      @records = [
        { "Id" => "", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31)
        },
        { "Id" => nil, "Name" => "Christmas Campaign 2016", "IsActive" => true,
          "StartDate" => Date.new(2016, 11, 25), "EndDate" => Date.new(2016, 12, 31)
        }
      ]
      @result = @client.upsert(@object_name, @records, "Id", callback_class: @callback, async: false)
    end

    it "upsert can process successfully" do
      expect(@result.is_a?(Seiun::Job)).to eq true
    end
  end

  describe '#query' do
    before do
      @soql = "SELECT Id, Name, IsActive, StartDate, EndDate FROM Campaign ORDER BY Id DESC LIMIT 10000"
      @result = @client.query(@object_name, @soql, callback_class: @callback)
    end

    it "query can process successfully" do
      expect(@result.is_a?(Array)).to eq true
    end
  end

  describe '#errors' do
    it "query can process successfully" do
      soql = "SELECT Id, Name, IsActive, StartDate, EndDate FROM Campaign WHERE StartDate = '2016-01-01' ORDER BY Id DESC LIMIT 10000"
      expect{@client.query(@object_name, soql, callback_class: @callback)}.to raise_error(Seiun::BatchFailError)
    end
  end
end
