module EBayEnterpriseAffiliateNetwork
  class APIResponse
    attr_reader :meta, :data, :request

    def initialize(response)
      @request = response.request
      body = JSON.parse(response.body)
      @meta = RecursiveOpenStruct.new(body["meta"])
      @data = parse(body["data"])
    end

    def all
      while meta.pagination.next
        uri = Addressable::URI.parse(meta.pagination.next.href)
        next_page_response = EBayEnterpriseAffiliateNetwork::Publisher.new.request(uri.origin + uri.path, uri.query_values)
        @meta = next_page_response.meta
        @data += next_page_response.data
      end
      @data
    end

    private

    def parse(raw_data)
      data = []
      data = [raw_data] if raw_data.is_a?(Hash) # If we got exactly one result, put it in an array.
      raw_data.each { |item| data << RecursiveOpenStruct.new(item) } if raw_data
      data
    end
  end
end
