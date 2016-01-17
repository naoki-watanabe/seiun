module Seiun
  class Connection
    def initialize(databasedotcom)
      @databasedotcom = databasedotcom
    end

    def create_job(data, callback: nil)
      connect(:create_job, data: data, callback: callback)
    end

    def close_job(data, job_id, callback: nil)
      connect(:close_job, data: data, job_id: job_id, callback: callback)
    end

    def add_query(soql, job_id, callback: nil)
      connect(:add_query, data: soql, job_id: job_id, callback: callback)
    end

    def add_batch(data, job_id, callback: nil)
      connect(:add_batch, data: data, job_id: job_id, callback: callback)
    end

    def get_job_details(job_id, callback: nil)
      connect(:get_job_details, job_id: job_id, callback: callback)
    end

    def get_batch_details(job_id, callback: nil)
      connect(:get_batch_details, job_id: job_id, callback: callback)
    end

    def get_result(job_id, batch_id, callback: nil)
      connect(:get_result, job_id: job_id, batch_id: batch_id, callback: callback)
    end

    def get_query_result(job_id, batch_id, result_id, callback: nil)
      connect(:get_query_result, job_id: job_id, batch_id: batch_id, result_id: result_id, callback: callback)
    end

    private

    def connect(type, data: nil, job_id: nil, batch_id: nil, result_id: nil, callback: nil)
      path = request_path(type, job_id, batch_id, result_id)
      callback.before_request(type, path.dup, data) if callback
      if callback && mock_body = callback.__send__("mock_response_#{type}")
        body = mock_body
      else
        response = nil
        raise_over_retry 3 do
          response = request(type, path, data, job_id, batch_id, result_id, callback: callback)
          response.value
        end
        body = response.body
      end
      callback.after_response(type, path, body) if callback
      body
    end

    def request(type, path, data, job_id, batch_id, result_id, callback: nil)
      https = Net::HTTP.new(instance_host, 443)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE if callback && callback.ssl_verify_none
      case type
      when :create_job, :close_job, :add_query, :add_batch
        https.post(path, data, headers)
      else
        https.get(path, headers)
      end
    end

    def request_path(type, job_id, batch_id, result_id)
      case type
      when :create_job
        "/services/async/#{api_version}/job"
      when :close_job, :get_job_details
        "/services/async/#{api_version}/job/#{job_id}"
      when :add_query, :add_batch, :get_batch_details
        "/services/async/#{api_version}/job/#{job_id}/batch"
      when :get_result
        "/services/async/#{api_version}/job/#{job_id}/batch/#{batch_id}/result"
      when :get_query_result
        "/services/async/#{api_version}/job/#{job_id}/batch/#{batch_id}/result/#{result_id}"
      end
    end

    def instance_host
      return @instance_host if @instance_host
      @databasedotcom.instance_url =~ /^https*\:\/\/([^\/]+)/
      @instance_host = $1
    end

    def headers
      { "X-SFDC-Session" => session_id, 'Content-Type' => 'application/xml; charset=UTF-8' }
    end

    def session_id
      @session_id ||= @databasedotcom.oauth_token
    end

    def api_version
      "35.0"
    end

    def raise_over_retry(times)
      count = 0
      begin
        yield
      rescue => ex
        count += 1
        if count >= times
          ex.is_a?(Net::HTTPResponse) ? raise(ex, ex.response.body) : raise(ex)
        end
        sleep 1
        retry
      end
    end
  end
end
