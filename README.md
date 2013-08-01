# eBay Enterprise Affiliate Network API

[![Gem Version](https://badge.fury.io/rb/ebay_enterprise_affiliate_network.png)](http://badge.fury.io/rb/ebay_enterprise_affiliate_network)
[![Build Status](https://travis-ci.org/rmarescu/ebay_enterprise_affiliate_network.png?branch=master)](https://travis-ci.org/rmarescu/ebay_enterprise_affiliate_network)

Ruby wrapper for [eBay Enterprise Affiliate Network API](http://help.pepperjamnetwork.com/api/) (formerly PepperJam Exchange API). Only [Publisher API](http://help.pepperjamnetwork.com/api/publisher) is supported at this moment. If you need [Advertiser API](http://help.pepperjamnetwork.com/api/advertiser) or [Partner API](http://help.pepperjamnetwork.com/api/partner), feel free to [contribute](#contributing).

For questions or bugs please [create an issue](../../issues/new).

## <a id="installation"></a>Installation

Add this line to your application's Gemfile:

    gem 'ebay_enterprise_affiliate_network'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ebay_enterprise_affiliate_network

## <a id="requirement"></a>Requirements

[Ruby](http://www.ruby-lang.org/en/downloads/) 1.9 or above.

## <a id="usage"></a>Usage

The gem is designed to support all existing and future [Publisher API](http://help.pepperjamnetwork.com/api/publisher) resources.

To start using the gem, you need to set up the api key first. If you use Ruby on Rails, the API key can be set in a configuration file (i.e. `app/config/initializers/ebay_enterprise_affiliate_network.rb`), otherwise just set it in your script. API Key can be found at http://www.pepperjamnetwork.com/affiliate/api/.

```ruby
require "ebay_enterprise_affiliate_network" # no need for RoR
EBayEnterpriseAffiliateNetwork.api_key = ENV["EEAN_API_KEY"]
```

### Examples

#### <a href="http://help.pepperjamnetwork.com/api/publisher#advertiser-category" target="_blank" title="Advertiser Categories">Advertiser Categories</a>

```ruby
publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
response = publisher.get("advertiser/category")
response.data.each do |category|
  puts "#{category.name} (ID #{category.id})"
end

# Retrieve the actual request URL sent to the API
puts response.request.uri.to_s
```

#### <a href="http://help.pepperjamnetwork.com/api/publisher#advertiser" target="_blank" title="Advertisers">Advertiser Details</a>

Get the list of [advertisers](http://help.pepperjamnetwork.com/api/publisher#advertiser) that you have a `joined` relationship with. The second argument of `get` method accepts a `Hash` of parameters. See the [API documentation](http://help.pepperjamnetwork.com/api/publisher) for a list of parameters for each API resource.
Note that the API resource used must match the ones available in documentation, except the `publisher/` prefix that needs to be removed.

```ruby
publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
response = publisher.get("advertiser", status: :joined)
# Return the number of total records
response.meta.pagination.total_results
# Return the number of pages
response.meta.pagination.total_pages

response.data.each do |advertiser|
  # Do something
end
```
If there are multiple pages (each page has a maximum of 500 records, value that cannot be changed), you can retrieve all pages by using the `all` method, as follows:

```ruby
response.all.each do |advertiser|
  # Do something
end
```
When using the `all` method, `response` object is updated with the data returned by the last API request (last page). `response.all` returns the `data` array.

#### <a href="http://help.pepperjamnetwork.com/api/publisher#creative-product" target="_blank" title="Product Creatives">Product Creatives</a>

Filter [Target](http://www.target.com) products by `canon camera` keywords.

```ruby
params = {
  programIds: 6759, # Target ID
  keywords: "canon camera"
}
publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
response = publisher.get("creative/product", params)
response.data.each do |product|
  puts "<a href=\"#{product.buy_url}\" title=\"#{product.name}\" target=\"_blank\">#{product.name}</a>"
end
```

#### <a href="http://help.pepperjamnetwork.com/api/publisher#report-transaction-details" target="_blank" title="Transaction Details">Transaction Details</a>

Retrieve all transactions in the last day

```ruby
require "date"
# Note that the API uses ET as time zone, although is not specified anywhere
yesterday = (Date.today - 1).to_s
today = Date.today.to_s
params = {
  startDate: yesterday,
  endDate: today,
  website: 12345 # replace with your website id
}
publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
response = publisher.get("report/transaction-details", params)
response.data.each do |transaction|
  # Generate report
end
```

Website ID can be retrieved from http://www.pepperjamnetwork.com/affiliate.

### Extra Configuration

* `EBayEnterpriseAffiliateNetwork.api_base_url` - default value is `http://api.pepperjamnetwork.com`
* `EBayEnterpriseAffiliateNetwork.api_version` - default value is `20120402`
* `EBayEnterpriseAffiliateNetwork.api_timeout` - the timeout set when initiating requests to eBay Enterprise Affiliate Network API (default value is 30 seconds)

## <a id="contributing"></a>Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a id="license"></a>License

[MIT](LICENSE.txt)
