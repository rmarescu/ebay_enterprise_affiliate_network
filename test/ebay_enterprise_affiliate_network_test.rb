require "test_helper"

class EBayEnterpriseAffiliateNetworkTest < Test::Unit::TestCase
  def test_with_invalid_key
    EBayEnterpriseAffiliateNetwork.api_key = nil
    ebay = EBayEnterpriseAffiliateNetwork::Publisher.new
    assert_raise EBayEnterpriseAffiliateNetwork::AuthenticationError do
      ebay.get('advertiser')
    end

    EBayEnterpriseAffiliateNetwork.api_key = "key with spaces"
    assert_raise EBayEnterpriseAffiliateNetwork::AuthenticationError do
      ebay.get('advertiser')
    end
  end

  def test_invalid_version
    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork.api_version = ""
    end

    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork.api_version = 0
    end
  end

  def test_invalid_timeout
    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork.api_timeout = ""
    end

    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork.api_timeout = "20"
    end

    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork.api_timeout = 0
    end

    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork.api_timeout = -1
    end
  end

  def test_new_publisher
    EBayEnterpriseAffiliateNetwork.api_key = "key"
    assert_nothing_raised do
      EBayEnterpriseAffiliateNetwork::Publisher.new
    end
  end

  def test_invalid_params_for_resource
    EBayEnterpriseAffiliateNetwork.api_key = "key"
    assert_raise ArgumentError do
      EBayEnterpriseAffiliateNetwork::Publisher.new.get("advertiser", "foo")
    end
  end

  def test_publisher_base_path
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    assert_equal "/#{EBayEnterpriseAffiliateNetwork.api_version}/publisher/", publisher.base_path
  end

  def test_raise_invalid_request_error_on_code_400
    EBayEnterpriseAffiliateNetwork.api_key = "key"
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    json_response = <<-JSON
    {
      "meta": {
        "status": { "code": 400, "message": "foo is not a valid program status option." },
        "requests": { "current": 384, "maximum": 1500 }
      },
      "data": []
    }
    JSON
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&status=foo").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(
          status: [400, "foo is not a valid program status option."],
          body: json_response,
          headers: {}
    )
    e = assert_raise EBayEnterpriseAffiliateNetwork::InvalidRequestError do
      publisher.get("advertiser", status: :foo)
    end
    assert_equal "foo is not a valid program status option. (Code 400)", e.to_s
  end

  def test_raise_error_on_code_500
    EBayEnterpriseAffiliateNetwork.api_key = "key"
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    json_response = <<-JSON
    {
      "meta": {
        "status": { "code": 500, "message": "Internal Server Error" },
        "requests": { "current": 384, "maximum": 1500 }
      },
      "data": []
    }
    JSON
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(
          status: [500, "Internal Server Error"],
          body: json_response,
          headers: {}
    )
    e = assert_raise EBayEnterpriseAffiliateNetwork::Error do
      publisher.get("advertiser/category")
    end
    assert_equal "Internal Server Error (Code 500)", e.to_s
  end

  def test_raise_error_on_code_401
    EBayEnterpriseAffiliateNetwork.api_key = "wrong_key"
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    json_response = <<-JSON
    {
      meta: {
        status: {
        code: 401,
        message: "Authentication error."
        }
      },
      data: []
    }
    JSON
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(
          status: [401, "Authentication error."],
          body: json_response,
          headers: {}
    )
    e = assert_raise EBayEnterpriseAffiliateNetwork::AuthenticationError do
      publisher.get("advertiser/category")
    end
    assert_equal "Authentication error. (Code 401)", e.to_s
  end

  def test_publisher_get_category_resource
    EBayEnterpriseAffiliateNetwork.api_key = "key"
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    json_response = <<-JSON
    {
      "meta": {
        "status": { "code": 200, "message": "OK" },
        "pagination": { "total_results": 3, "total_pages": 1 },
        "requests": { "current": 359, "maximum": 1500 }
      },
      "data": [
        { "name": "Commerce", "id": "1" },
        { "name": "Computer & Electronics", "id": "2" },
        { "name": "Education", "id": "3" },
        { "name": "Accessories", "id": "7" }
      ]
    }
    JSON
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(status: 200, body: json_response, headers: {})

    response = publisher.get("advertiser/category")
    check_results(response)

    assert_equal 200, response.meta.status.code
    assert_equal 3, response.meta.pagination.total_results
    assert_equal 1, response.meta.pagination.total_pages
    assert_equal 4, response.data.size
    assert_equal "Commerce", response.data.first.name
    assert_equal "1", response.data.first.id
    assert_equal "Accessories", response.data.last.name
    assert_equal "7", response.data.last.id
  end

  def test_publisher_get_all_results
    EBayEnterpriseAffiliateNetwork.api_key = "key"
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    response_page_1 = <<-JSON
    {
      "meta": {
        "status": { "code": 200, "message": "OK" },
        "pagination": {
          "total_results": 10,
          "total_pages": 3,
          "next": {
            "rel": "next",
            "href": "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&page=2",
            "description": "Next Page"
          }
        },
        "requests": { "current": 359, "maximum": 1500 }
      },
      "data": [
        { "name": "Commerce", "id": "1" },
        { "name": "Computer & Electronics", "id": "2" },
        { "name": "Education", "id": "3" },
        { "name": "Accessories", "id": "7" }
      ]
    }
    JSON
    response_page_2 = <<-JSON
    {
      "meta": {
        "status": { "code": 200, "message": "OK" },
        "pagination": {
          "total_results": 10,
          "total_pages": 3,
          "next": {
            "rel": "next",
            "href": "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&page=3",
            "description": "Next Page"
          },
          "prev": {
            "rel": "prev",
            "href": "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&page=1",
            "description": "Previous Page"
          }
        },
        "requests": { "current": 360, "maximum": 1500 }
      },
      "data": [
        { "name": "Art/Photo/Music", "id": "9" },
        { "name": "Automotive", "id": "11" },
        { "name": "Books/Media", "id": "13" },
        { "name": "Business", "id": "15" }
      ]
    }
    JSON
    response_page_3 = <<-JSON
    {
      "meta": {
        "status": { "code": 200, "message": "OK" },
        "pagination": {
          "total_results": 10,
          "total_pages": 3,
          "prev": {
            "rel": "prev",
            "href": "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&page=2",
            "description": "Previous Page"
          }
        },
        "requests": { "current": 361, "maximum": 1500 }
      },
      "data": [
        { "name": "Careers", "id": "17" },
        { "name": "Clothing/Apparel", "id": "19" },
        { "name": "Entertainment", "id": "23" }
      ]
    }
    JSON
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(status: 200, body: response_page_1, headers: {})

    response = publisher.get("advertiser/category")
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&page=2").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(status: 200, body: response_page_2, headers: {})
    stub_request(
      :get,
      "http://api.pepperjamnetwork.com/20120402/publisher/advertiser/category?apiKey=#{EBayEnterpriseAffiliateNetwork.api_key}&format=json&page=3").
        with(headers: { "Accept" => "*/*", "Accept-Encoding" => /.*/, "User-Agent" => /.*/ }).
        to_return(status: 200, body: response_page_3, headers: {})
    all_categories = response.all
    check_results(response)

    assert_equal 11, all_categories.count
    assert_equal 23, all_categories.last.id.to_i
  end

  private

  def check_results(response)
    assert_instance_of(RecursiveOpenStruct, response.meta)
    assert_instance_of(Fixnum, response.meta.status.code)
    assert_instance_of(String, response.meta.status.message)
    assert_instance_of(Fixnum, response.meta.pagination.total_results)
    assert_instance_of(Fixnum, response.meta.pagination.total_pages)
    assert_instance_of(Array, response.data)

    response.data.each do |item|
      assert_instance_of(RecursiveOpenStruct, item)
      assert_respond_to(item, :name)
    end
  end
end
