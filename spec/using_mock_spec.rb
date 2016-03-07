require 'spec_helper'

describe "Test using mock" do
  before do
    @client = Seiun::Client.new
    @callback = SeiunSpec::Callbacks::WithMock
    @callback.init
    @object_name = "Campaign"
  end

  describe '#upsert' do
    before do
      @records = [
        @callback.new("Id" => "001D000000ISUr3IAH", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        ),
        @callback.new("Id" => nil, "Name" => "Christmas Campaign 2016", "IsActive" => true,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2016, 11, 25), "EndDate" => Date.new(2016, 12, 31),
          "TimeField__c" => DateTime.new(2016, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1" ], "NullField__c" => nil
        )
      ]
      @client.upsert(@object_name, @records, "Id", callback_class: @callback)
    end

    it "operation, object_name, ext_field_name are reflected to request xml" do
      Seiun::XMLParsers::JobXML.each(@callback.requests[:create_job][0]) do |response|
        expect(response.operation).to eq "upsert"
        expect(response.object).to eq @object_name.to_s
        expect(response.external_id_field_name).to eq "Id"
      end
    end

    it "job_id is reflected to requests" do
      job_id = nil
      Seiun::XMLParsers::JobXML.each(@callback.responses[:create_job][0]) do |response|
        job_id = response.id
      end
      @callback.paths[:add_batch][0] =~ /\/job\/([^\/]+)/
      expect($1).to eq job_id.to_s
      @callback.paths[:close_job][0] =~ /\/job\/([^\/]+)/
      expect($1).to eq job_id.to_s
    end

    it "records are reflected to request xml" do
      ids = []
      string_fields = []
      date_fields = []
      boolean_fields = []
      time_fields = []
      multi_select_fields = []
      null_fields = []
      Seiun::XMLParsers::RecordXML.each(@callback.requests[:add_batch][0], find_tag: "sObject") do |response|
        ids << response.to_hash["Id"]
        string_fields << response.to_hash["Name"]
        date_fields << response.to_hash["StartDate"]
        boolean_fields << response.to_hash["IsActive"]
        time_fields << response.to_hash["TimeField__c"]
        multi_select_fields << response.to_hash["MultiSelectField__c"]
        null_fields << response.to_hash["NullField__c"]
      end
      expect(ids.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Id"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(string_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Name"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(date_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["StartDate"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(boolean_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["IsActive"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(time_fields[0]).to eq @records.map{|c| c.hashalize["TimeField__c"] }[0]
      expect(multi_select_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["MultiSelectField__c"].join(";") }.sort{|a,b| a.to_s <=> b.to_s}
      expect(null_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["NullField__c"] }.sort{|a,b| a.to_s <=> b.to_s}
    end

    it "after_create_job callback returns jobs" do
      expect(@callback.created_jobs[0].class).to eq Seiun::Job
      expect(@callback.created_jobs[0].id).to eq "75028000000oEcVAAU"
    end

    it "after_close_job callback returns jobs" do
      expect(@callback.closed_jobs[0].class).to eq Seiun::Job
      expect(@callback.closed_jobs[0].id).to eq "75028000000oEcVAAU"
    end

    it "before_build_xml callback returns records" do
      expect(@callback.records.map{|r| r.instance_variable_get(:@record) }).to eq @records
    end

    it "after_build_xml callback returns REXML::Document" do
      expect(@callback.xml_size).to eq @records.size
    end
  end

  describe '#insert' do
    before do
      @records = [
        @callback.new("Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        ),
        @callback.new("Name" => "Christmas Campaign 2016", "IsActive" => true,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2016, 11, 25), "EndDate" => Date.new(2016, 12, 31),
          "TimeField__c" => DateTime.new(2016, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1" ], "NullField__c" => nil
        )
      ]
      @client.insert(@object_name, @records, callback_class: @callback)
    end

    it "operation, object_name are reflected to request xml" do
      Seiun::XMLParsers::JobXML.each(@callback.requests[:create_job][0]) do |response|
        expect(response.operation).to eq "insert"
        expect(response.object).to eq @object_name.to_s
      end
    end

    it "records are reflected to request xml" do
      ids = []
      string_fields = []
      date_fields = []
      boolean_fields = []
      time_fields = []
      multi_select_fields = []
      null_fields = []
      Seiun::XMLParsers::RecordXML.each(@callback.requests[:add_batch][0], find_tag: "sObject") do |response|
        ids << response.to_hash["Id"]
        string_fields << response.to_hash["Name"]
        date_fields << response.to_hash["StartDate"]
        boolean_fields << response.to_hash["IsActive"]
        time_fields << response.to_hash["TimeField__c"]
        multi_select_fields << response.to_hash["MultiSelectField__c"]
        null_fields << response.to_hash["NullField__c"]
      end
      expect(ids.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Id"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(string_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Name"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(date_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["StartDate"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(boolean_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["IsActive"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(time_fields[0]).to eq @records.map{|c| c.hashalize["TimeField__c"] }[0]
      expect(multi_select_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["MultiSelectField__c"].join(";") }.sort{|a,b| a.to_s <=> b.to_s}
      expect(null_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["NullField__c"] }.sort{|a,b| a.to_s <=> b.to_s}
    end
  end

  describe '#upsert_paging' do
    before do
      @count = 10_001
      records = []
      @count.times do |i|
        records << { "Id" => "001D000000ISUr3IAH", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        }
      end
      @job = @client.upsert(@object_name, records, "Id", callback_class: @callback)
    end

    it "There are 1 job_id and 2 batches each 10,000 records" do
      expect(@job.class).to eq Seiun::Job
      operations = []
      @callback.requests[:create_job].each do |request_body|
        Seiun::XMLParsers::JobXML.each(request_body) do |response|
          operations << response.operation
        end
      end
      expect(operations).to eq ["upsert"]
      count = []
      @callback.requests[:add_batch].each_with_index do |request_body, index|
        count[index] = 0
        Seiun::XMLParsers::RecordXML.each(request_body, find_tag: "sObject") do |response|
          count[index] += 1
        end
      end
      expect(count).to eq [10_000, 1]
    end
  end


  describe '#upsert_queue' do
    before do
      @count = 10_001
      queue = @client.upsert_queue(@object_name, "Id", callback_class: @callback)
      @count.times do |i|
        queue << { "Id" => "001D000000ISUr3IAH", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        }
      end
      @jobs = queue.close
    end

    it "There are 2 job_id each 10,000 records" do
      expect(@jobs.map{|job| job.class }).to eq [Seiun::Job, Seiun::Job]
      operations = []
      @callback.requests[:create_job].each do |request_body|
        Seiun::XMLParsers::JobXML.each(request_body) do |response|
          operations << response.operation
        end
      end
      expect(operations).to eq ["upsert", "upsert"]
      count = []
      @callback.requests[:add_batch].each_with_index do |request_body, index|
        count[index] = 0
        Seiun::XMLParsers::RecordXML.each(request_body, find_tag: "sObject") do |response|
          count[index] += 1
        end
      end
      expect(count).to eq [10_000, 1]
    end
  end

  describe '#insert' do
    before do
      @records = [
        @callback.new("Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        ),
        @callback.new("Name" => "Christmas Campaign 2016", "IsActive" => true,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2016, 11, 25), "EndDate" => Date.new(2016, 12, 31),
          "TimeField__c" => DateTime.new(2016, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1" ], "NullField__c" => nil
        )
      ]
      @client.insert(@object_name, @records, callback_class: @callback)
    end

    it "operation, object_name are reflected to request xml" do
      Seiun::XMLParsers::JobXML.each(@callback.requests[:create_job][0]) do |response|
        expect(response.operation).to eq "insert"
        expect(response.object).to eq @object_name.to_s
      end
    end

    it "records are reflected to request xml" do
      ids = []
      string_fields = []
      date_fields = []
      boolean_fields = []
      time_fields = []
      multi_select_fields = []
      null_fields = []
      Seiun::XMLParsers::RecordXML.each(@callback.requests[:add_batch][0], find_tag: "sObject") do |response|
        ids << response.to_hash["Id"]
        string_fields << response.to_hash["Name"]
        date_fields << response.to_hash["StartDate"]
        boolean_fields << response.to_hash["IsActive"]
        time_fields << response.to_hash["TimeField__c"]
        multi_select_fields << response.to_hash["MultiSelectField__c"]
        null_fields << response.to_hash["NullField__c"]
      end
      expect(ids.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Id"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(string_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Name"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(date_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["StartDate"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(boolean_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["IsActive"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(time_fields[0]).to eq @records.map{|c| c.hashalize["TimeField__c"] }[0]
      expect(multi_select_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["MultiSelectField__c"].join(";") }.sort{|a,b| a.to_s <=> b.to_s}
      expect(null_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["NullField__c"] }.sort{|a,b| a.to_s <=> b.to_s}
    end

    it "before_build_xml callback returns records" do
      expect(@callback.records.map{|r| r.instance_variable_get(:@record) }).to eq @records
    end

    it "after_build_xml callback returns REXML::Document" do
      expect(@callback.xml_size).to eq @records.size
    end
  end

  describe '#insert_queue' do
    before do
      @count = 10_001
      queue = @client.insert_queue(@object_name, callback_class: @callback)
      @count.times do |i|
        queue << { "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        }
      end
      @jobs = queue.close
    end

    it "There are 2 job_id" do
      expect(@jobs.map{|job| job.operation }).to eq [:insert, :insert]
    end
  end

  describe '#update' do
    before do
      @records = [
        @callback.new("Id" => "001D000000ISUr3IAH", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        ),
        @callback.new("Id" => "001D000000ISUt3IAH", "Name" => "Christmas Campaign 2016", "IsActive" => true,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2016, 11, 25), "EndDate" => Date.new(2016, 12, 31),
          "TimeField__c" => DateTime.new(2016, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1" ], "NullField__c" => nil
        )
      ]
      @client.update(@object_name, @records, callback_class: @callback)
    end

    it "operation, object_name are reflected to request xml" do
      Seiun::XMLParsers::JobXML.each(@callback.requests[:create_job][0]) do |response|
        expect(response.operation).to eq "update"
        expect(response.object).to eq @object_name.to_s
      end
    end

    it "records are reflected to request xml" do
      ids = []
      string_fields = []
      date_fields = []
      boolean_fields = []
      time_fields = []
      multi_select_fields = []
      null_fields = []
      Seiun::XMLParsers::RecordXML.each(@callback.requests[:add_batch][0], find_tag: "sObject") do |response|
        ids << response.to_hash["Id"]
        string_fields << response.to_hash["Name"]
        date_fields << response.to_hash["StartDate"]
        boolean_fields << response.to_hash["IsActive"]
        time_fields << response.to_hash["TimeField__c"]
        multi_select_fields << response.to_hash["MultiSelectField__c"]
        null_fields << response.to_hash["NullField__c"]
      end
      expect(ids.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Id"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(string_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Name"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(date_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["StartDate"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(boolean_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["IsActive"] }.sort{|a,b| a.to_s <=> b.to_s}
      expect(time_fields[0]).to eq @records.map{|c| c.hashalize["TimeField__c"] }[0]
      expect(multi_select_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["MultiSelectField__c"].join(";") }.sort{|a,b| a.to_s <=> b.to_s}
      expect(null_fields.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["NullField__c"] }.sort{|a,b| a.to_s <=> b.to_s}
    end

    it "before_build_xml callback returns records" do
      expect(@callback.records.map{|r| r.instance_variable_get(:@record) }).to eq @records
    end

    it "after_build_xml callback returns REXML::Document" do
      expect(@callback.xml_size).to eq @records.size
    end
  end

  describe '#update_queue' do
    before do
      @count = 10_001
      queue = @client.update_queue(@object_name, callback_class: @callback)
      @count.times do |i|
        queue << { "Id" => "001D000000ISUr3IAH", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        }
      end
      @jobs = queue.close
    end

    it "There are 2 job_id" do
      expect(@jobs.map{|job| job.operation }).to eq [:update, :update]
    end
  end

  describe '#dalete' do
    before do
      @records = [
        @callback.new("Id" => "001D000000ISUr3IAH"), @callback.new("Id" => "001D000000ISUt3IAH")
      ]
      @client.delete(@object_name, @records, callback_class: @callback)
    end

    it "operation, object_name are reflected to request xml" do
      Seiun::XMLParsers::JobXML.each(@callback.requests[:create_job][0]) do |response|
        expect(response.operation).to eq "delete"
        expect(response.object).to eq @object_name.to_s
      end
    end

    it "records are reflected to request xml" do
      ids = []
      Seiun::XMLParsers::RecordXML.each(@callback.requests[:add_batch][0], find_tag: "sObject") do |response|
        ids << response.to_hash["Id"]
      end
      expect(ids.sort{|a,b| a.to_s <=> b.to_s}).to eq @records.map{|c| c.hashalize["Id"] }.sort{|a,b| a.to_s <=> b.to_s}
    end

    it "before_build_xml callback returns records" do
      expect(@callback.records.map{|r| r.instance_variable_get(:@record) }).to eq @records
    end

    it "after_build_xml callback returns REXML::Document" do
      expect(@callback.xml_size).to eq @records.size
    end
  end

  describe '#delete_queue' do
    before do
      @count = 10_001
      queue = @client.delete_queue(@object_name, callback_class: @callback)
      @count.times do |i|
        queue << { "Id" => "001D000000ISUr3IAH" }
      end
      @jobs = queue.close
    end

    it "There are 2 job_id" do
      expect(@jobs.map{|job| job.operation }).to eq [:delete, :delete]
    end
  end

  describe '#query' do
    before do
      @soql = "SELECT Id, Name, IsActive, Parent, StartDate, EndDate, DateTimeField__c, MultiSelectField__c, NullField__c" +
        " FROM Campaign ORDER BY Id DESC LIMIT 10000"
      @result = @client.query(@object_name, @soql, callback_class: @callback)
    end

    it "soql is reflected to request" do
      expect(@callback.requests[:add_query][0]).to eq @soql
    end

    it "job_id is reflected to requests" do
      job_id = nil
      Seiun::XMLParsers::JobXML.each(@callback.responses[:create_job][0]) do |response|
        job_id = response.id
      end
      @callback.paths[:add_query][0] =~ /\/job\/([^\/]+)/
      expect($1).to eq job_id.to_s
      @callback.paths[:get_batch_details][0] =~ /\/job\/([^\/]+)/
      expect($1).to eq job_id.to_s
      @callback.paths[:get_result][0] =~ /\/job\/([^\/]+)/
      expect($1).to eq job_id.to_s
      @callback.paths[:get_query_result][0] =~ /\/job\/([^\/]+)/
      expect($1).to eq job_id.to_s
    end

    it "batch_id is reflected to requests" do
      batch_id = nil
      Seiun::XMLParsers::BatchXML.each(@callback.responses[:add_query][0]) do |response|
        batch_id = response.id
      end
      @callback.paths[:get_result][0] =~ /\/batch\/([^\/]+)/
      expect($1).to eq batch_id.to_s
      @callback.paths[:get_query_result][0] =~ /\/batch\/([^\/]+)/
      expect($1).to eq batch_id.to_s
    end

    it "result_id is reflected to requests" do
      result_id = nil
      Seiun::XMLParsers::ResultXML.each(@callback.responses[:get_result][0]) do |response|
        result_id = response.result_id
      end
      @callback.paths[:get_query_result][0] =~ /\/result\/([^\/]+)/
      expect($1).to eq result_id.to_s
    end
  end

  describe "#check_result" do
    before do
      @records = [
        @callback.new("Id" => "001D000000ISUr3IAH", "Name" => "Christmas Campaign 2015", "IsActive" => false,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2015, 11, 27), "EndDate" => Date.new(2015, 12, 31),
          "TimeField__c" => Time.local(2015, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1", "Selection2" ], "NullField__c" => nil
        ),
        @callback.new("Id" => nil, "Name" => "Christmas Campaign 2016", "IsActive" => true,
          "Parent" => { "Name" => "Christmas Campaigns" },
          "StartDate" => Date.new(2016, 11, 25), "EndDate" => Date.new(2016, 12, 31),
          "TimeField__c" => DateTime.new(2016, 11, 1, 9, 0, 0),
          "MultiSelectField__c" => [ "Selection1" ], "NullField__c" => nil
        )
      ]
      upsert_job = @client.upsert(@object_name, @records, "Id", callback_class: SeiunSpec::Callbacks::WithMock)
      @callback.init
      check_job = @client.find_job(upsert_job.id, callback_class: @callback)
      @results = []
      check_job.each_result do |hash|
        @results << hash
      end
    end

    it "connect selesforce to check" do
      expect(@callback.paths.keys).to eq [:get_job_details, :get_batch_details, :get_result]
    end

    it "get success" do
      successes = @results.map{|r| r["success"] }
      expect(successes.all?{|s| [true, false].include?(s) }).to eq true
    end
  end
end
