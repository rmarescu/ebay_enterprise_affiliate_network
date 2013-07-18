require "addressable/uri"
require "cgi"
require "htmlentities"
require "httparty"
require "json"
require "net/http"
require "recursive_open_struct"
require "uri"

# Version
require "ebay_enterprise_affiliate_network/version"

# Resources
require "ebay_enterprise_affiliate_network/api_resource"
require "ebay_enterprise_affiliate_network/publisher"
require "ebay_enterprise_affiliate_network/api_response"

# Errors
require "ebay_enterprise_affiliate_network/errors/error"
require "ebay_enterprise_affiliate_network/errors/authentication_error"
require "ebay_enterprise_affiliate_network/errors/connection_error"
require "ebay_enterprise_affiliate_network/errors/invalid_request_error"

module EBayEnterpriseAffiliateNetwork
  @api_base_url = "http://api.pepperjamnetwork.com"
  @api_version  = 20120402
  @api_timeout  = 30

  class << self
    attr_accessor :api_key, :api_base_url
    attr_reader :api_version, :api_timeout
  end

  def self.api_version=(version)
    raise ArgumentError, "Version must be a Fixnum (YYYYMMDD format); got #{version.class} instead." unless version.is_a? Fixnum
    raise ArgumentError, "Please provide the version of the API Key." unless version > 0
    @api_version = version
  end

  def self.api_timeout=(timeout)
    raise ArgumentError, "Timeout must be a Fixnum; got #{timeout.class} instead" unless timeout.is_a? Fixnum
    raise ArgumentError, "Timeout must be > 0; got #{timeout} instead" unless timeout > 0
    @api_timeout = timeout
  end
end
