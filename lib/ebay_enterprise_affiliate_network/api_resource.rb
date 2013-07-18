module EBayEnterpriseAffiliateNetwork
  class APIResource
    include HTTParty

    def class_name
      self.class.name.split('::')[-1]
    end

    def base_path
      if self == APIResource
        raise NotImplementedError.new("APIResource is an abstract class. You should perform actions on its subclasses (i.e. Publisher)")
      end
      "/#{EBayEnterpriseAffiliateNetwork.api_version}/#{CGI.escape(class_name.downcase)}/"
    end

    def get(api_resource, params = {})
      @resource ||= api_resource
      unless api_key ||= EBayEnterpriseAffiliateNetwork.api_key
        raise AuthenticationError.new(
          "No API key provided. Set your API key using 'EBayEnterpriseAffiliateNetwork.api_key = <API-KEY>'. " +
          "You can retrieve your API key from the eBay Enterprise web interface. " +
          "See http://www.pepperjamnetwork.com/affiliate/api/ for details."
        )
      end
      if api_key =~ /\s/
        raise AuthenticationError.new(
          "Your API key looks invalid. " +
          "Double-check your API key at http://www.pepperjamnetwork.com/affiliate/api/"
        )
      end
      raise ArgumentError, "Params must be a Hash; got #{params.class} instead" unless params.is_a? Hash

      params.merge!({
        apiKey: api_key,
        format: :json
      })
      resource_url = EBayEnterpriseAffiliateNetwork.api_base_url + base_path + api_resource
      request(resource_url, params)
    end

    def request(resource_url, params)
      timeout = EBayEnterpriseAffiliateNetwork.api_timeout
      begin
        response = self.class.get(resource_url, query: params, timeout: timeout)
      rescue Timeout::Error
        raise ConnectionError.new("Timeout error (#{timeout}s)")
      end
      process(response)
    end

    private

    def process(response)
      case response.code
      when 200, 201, 204
        APIResponse.new(response)
      when 400, 404
        raise InvalidRequestError.new(response.message, response.code)
      when 401
        raise AuthenticationError.new(response.message, response.code)
      else
        raise Error.new(response.message, response.code)
      end
    end
  end
end
