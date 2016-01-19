module SeiunSpec
  module Callbacks
    class WithMock < Base
      seiun_hashalize :hashalize
      seiun_before_build_xml :before_build_xml
      seiun_after_build_xml :after_build_xml
      seiun_before_request :before_request
      seiun_after_response :after_response

      seiun_mock_response_create_job        :create_job
      seiun_mock_response_close_job         :close_job
      seiun_mock_response_add_query         :add_query
      seiun_mock_response_add_batch         :add_batch
      seiun_mock_response_get_job_details   :get_job_details
      seiun_mock_response_get_batch_details :get_batch_details
      seiun_mock_response_get_result        :get_result
      seiun_mock_response_get_query_result  :get_query_result  

      class << self
        def create_job(operation: nil)
          <<EOS
<?xml version="1.0" encoding="UTF-8"?><jobInfo
   xmlns="http://www.force.com/2009/06/asyncapi/dataload">
 <id>75028000000oEcVAAU</id>
 <operation>upsert</operation>
 <object>Campaign</object>
 <createdById>00528000001lckgAAA</createdById>
 <createdDate>2015-12-30T14:51:51.000Z</createdDate>
 <systemModstamp>2015-12-30T14:51:51.000Z</systemModstamp>
 <state>Open</state>
 <externalIdFieldName>Id</externalIdFieldName>
 <concurrencyMode>Parallel</concurrencyMode>
 <contentType>XML</contentType>
 <numberBatchesQueued>0</numberBatchesQueued>
 <numberBatchesInProgress>0</numberBatchesInProgress>
 <numberBatchesCompleted>0</numberBatchesCompleted>
 <numberBatchesFailed>0</numberBatchesFailed>
 <numberBatchesTotal>0</numberBatchesTotal>
 <numberRecordsProcessed>0</numberRecordsProcessed>
 <numberRetries>0</numberRetries>
 <apiVersion>35.0</apiVersion>
 <numberRecordsFailed>0</numberRecordsFailed>
 <totalProcessingTime>0</totalProcessingTime>
 <apiActiveProcessingTime>0</apiActiveProcessingTime>
 <apexProcessingTime>0</apexProcessingTime>
</jobInfo>
EOS
        end

        def close_job(operation: nil)
          <<EOS
<?xml version="1.0" encoding="UTF-8"?><jobInfo
   xmlns="http://www.force.com/2009/06/asyncapi/dataload">
 <id>75028000000oEcVAAU</id>
 <operation>upsert</operation>
 <object>Campaign</object>
 <createdById>00528000001lckgAAA</createdById>
 <createdDate>2015-12-30T14:51:51.000Z</createdDate>
 <systemModstamp>2015-12-30T14:51:51.000Z</systemModstamp>
 <state>Closed</state>
 <externalIdFieldName>Id</externalIdFieldName>
 <concurrencyMode>Parallel</concurrencyMode>
 <contentType>XML</contentType>
 <numberBatchesQueued>0</numberBatchesQueued>
 <numberBatchesInProgress>1</numberBatchesInProgress>
 <numberBatchesCompleted>0</numberBatchesCompleted>
 <numberBatchesFailed>0</numberBatchesFailed>
 <numberBatchesTotal>1</numberBatchesTotal>
 <numberRecordsProcessed>0</numberRecordsProcessed>
 <numberRetries>0</numberRetries>
 <apiVersion>35.0</apiVersion>
 <numberRecordsFailed>0</numberRecordsFailed>
 <totalProcessingTime>0</totalProcessingTime>
 <apiActiveProcessingTime>0</apiActiveProcessingTime>
 <apexProcessingTime>0</apexProcessingTime>
</jobInfo>
EOS
        end

        def add_query(operation: nil)
          add_batch
        end

        def add_batch(operation: nil)
          <<EOS
<?xml version="1.0" encoding="UTF-8"?><batchInfo
   xmlns="http://www.force.com/2009/06/asyncapi/dataload">
 <id>751280000016CJ3AAM</id>
 <jobId>75028000000oEcaAAE</jobId>
 <state>Queued</state>
 <createdDate>2015-12-30T14:51:54.000Z</createdDate>
 <systemModstamp>2015-12-30T14:51:54.000Z</systemModstamp>
 <numberRecordsProcessed>0</numberRecordsProcessed>
 <numberRecordsFailed>0</numberRecordsFailed>
 <totalProcessingTime>0</totalProcessingTime>
 <apiActiveProcessingTime>0</apiActiveProcessingTime>
 <apexProcessingTime>0</apexProcessingTime>
</batchInfo>
EOS
        end

        def get_job_details(operation: nil)
          <<EOS
<?xml version="1.0" encoding="UTF-8"?><jobInfo
   xmlns="http://www.force.com/2009/06/asyncapi/dataload">
 <id>75028000000oEcaAAE</id>
 <operation>upsert</operation>
 <object>Campaign</object>
 <createdById>00528000001lckgAAA</createdById>
 <createdDate>2016-01-15T18:46:30.000Z</createdDate>
 <systemModstamp>2016-01-15T18:46:30.000Z</systemModstamp>
 <state>Closed</state>
 <externalIdFieldName>Id</externalIdFieldName>
 <concurrencyMode>Parallel</concurrencyMode>
 <contentType>XML</contentType>
 <numberBatchesQueued>0</numberBatchesQueued>
 <numberBatchesInProgress>0</numberBatchesInProgress>
 <numberBatchesCompleted>1</numberBatchesCompleted>
 <numberBatchesFailed>0</numberBatchesFailed>
 <numberBatchesTotal>1</numberBatchesTotal>
 <numberRecordsProcessed>2</numberRecordsProcessed>
 <numberRetries>0</numberRetries>
 <apiVersion>35.0</apiVersion>
 <numberRecordsFailed>0</numberRecordsFailed>
 <totalProcessingTime>130</totalProcessingTime>
 <apiActiveProcessingTime>77</apiActiveProcessingTime>
 <apexProcessingTime>0</apexProcessingTime>
</jobInfo>
EOS
        end

        def get_batch_details(operation: nil)
          <<EOS
<?xml version="1.0" encoding="UTF-8"?><batchInfoList
   xmlns="http://www.force.com/2009/06/asyncapi/dataload">
 <batchInfo>
  <id>751280000016CJ3AAM</id>
  <jobId>75028000000oEcaAAE</jobId>
  <state>Completed</state>
  <createdDate>2015-12-30T14:51:54.000Z</createdDate>
  <systemModstamp>2015-12-30T14:51:54.000Z</systemModstamp>
  <numberRecordsProcessed>7</numberRecordsProcessed>
  <numberRecordsFailed>0</numberRecordsFailed>
  <totalProcessingTime>0</totalProcessingTime>
  <apiActiveProcessingTime>0</apiActiveProcessingTime>
  <apexProcessingTime>0</apexProcessingTime>
 </batchInfo>
</batchInfoList>
EOS
        end

        def get_result(operation: nil)
          if operation == :query
            <<EOS.gsub(/>\s+</, '><')
<result-list xmlns="http://www.force.com/2009/06/asyncapi/dataload">
  <result>75228000000YhJP</result>
</result-list>
EOS
          else
            <<EOS.gsub(/>\s+</, '><')
<?xml version="1.0" encoding="UTF-8"?>
<results xmlns="http://www.force.com/2009/06/asyncapi/dataload">
  <result>
    <id>70128000000bMzZAAU</id>
    <success>true</success>
    <created>true</created>
  </result>
  <result>
    <errors>
      <message>Something Error</message>
      <statusCode>SOMETHING_ERROR</statusCode>
    </errors>
    <success>false</success>
    <created>true</created>
  </result>
</results>
EOS
          end
        end

        def get_query_result(operation: nil)
          <<EOS.gsub(/>\s+</, '><')
<?xml version="1.0" encoding="UTF-8"?>
<queryResult xmlns="http://www.force.com/2009/06/asyncapi/dataload" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <records xsi:type="sObject">
    <type>Campaign</type>
    <Id>70128000000ax3UAAQ</Id>
    <Id>70128000000ax3UAAQ</Id>
    <Name>Christmas Campaign 2016</Name>
    <IsActive>true</IsActive>
    <Parent>P01D000000ISUr3IAH</Parent>
    <StartDate>2016-11-25</StartDate>
    <EndDate>2016-12-31</EndDate>
    <TimeField__c>2016-11-01T09:00:00.000Z</TimeField__c>
    <MultiSelectField__c>Selection1</MultiSelectField__c>
    <NullField__c xsi:nil="true" />
  </records>
  <records xsi:type="sObject">
    <type>Campaign</type>
    <Id>70128000000ax3TAAQ</Id>
    <Id>70128000000ax3TAAQ</Id>
    <Name>Christmas Campaign 2015</Name>
    <IsActive>false</IsActive>
    <Parent>P01D000000ISUr3IAH</Parent>
    <StartDate>2015-11-27</StartDate>
    <EndDate>2015-12-31</EndDate>
    <TimeField__c>2015-11-01T09:00:00.000+09:00</TimeField__c>
    <MultiSelectField__c>Selection1;Selection2</MultiSelectField__c>
    <NullField__c xsi:nil="true" />
  </records>
</queryResult>
EOS
        end
      end
    end
  end
end
