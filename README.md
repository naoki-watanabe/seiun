![Seiun](https://s3-ap-northeast-1.amazonaws.com/naoki-watanabe/GitHub/seiun_20160101.jpg)

## What's this?

* This is the Salesforce client for ruby environment.
* You can read/write Salesforce database via Salesforce Bulk API with this gem.
* "Winter '16" version correspondence.

## Faster than popular gem

This gem "seiun" is **33 times** as fast as "salesforce_bulk_api" gem that is popular to use Salesforce Bulk API.

About system time, this gem more than 1,000 times as fast as "salesforce_bulk_api" gem.

```
                                user     system      total        real
seiun#0
seiun#0                    33.020000   0.290000  33.310000 ( 33.310086)
salesforce_bulk_api#0
salesforce_bulk_api#0     1457.280000 316.500000 1773.780000 (1773.840572)

```

The above measure time from receiving arguments to sending xml (10,000 records) on Amazon EC2 t2.medium instance.

## Callbacks

You can use original callback class.

```ruby
# example
class SomeModel < ActiveRecord::Base
  include Seiun::Callback::Extends
  seiun_before_request :before_request  # call from gem
  seiun_hashalize :hashalize            # call from gem

  def hashalize
    # return hash object to write salesforce database
  end
end

# You can pass ActiveRecord Object without converting
@seiun.insert("TableName", SomeModel.where(category: "something"), callback_class: SomeModel)

```

## Queues

You can use insert/update/upsert/delete queues.
You are not a cause for concern about the record size limit. Queue process each 10,000 records.

```ruby
# example
queue = @seiun.insert_queue("TableName")
SomeMode.find_each{|model| queue << model if model.available? }
queue.close

```

## Mocks

With mocks, you can test your application without connecting Salesforce API.

```ruby
class Mocks
  include Seiun::Callback::Extends
  seiun_mock_response_create_job :create_job

  # This gem process as receive response below
  def create_job
    <<EOS
<?xml version="1.0" encoding="UTF-8"?><jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
 <id>75028000000oEcVAAU</id>
 <operation>upsert</operation>
 <object>Campaign</object>
 <createdById>00528000001lckgAAA</createdById>
 <createdDate>2015-12-30T14:51:51.000Z</createdDate>
 <systemModstamp>2015-12-30T14:51:51.000Z</systemModstamp>
 <state>Open</state>
</jobInfo>
EOS
  end

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seiun'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seiun

## Usage

This gem dependent on [databasedotcom](https://github.com/heroku/databasedotcom).

```ruby
databasedotcom = Databasedotcom::Client.new(client_id: "customer_key", client_secret: "consumer_secret")
databasedotcom.authenticate(:username => "username", :password => "password_woth_security_token")
@seiun = Seiun::Client.new(databasedotcom: databasedotcom)

# example: insert
@seiun.insert("TableName", records)

# example: query
@seiun.query("TableName", "SELECT Id, Name FROM Account ORDER BY Id LIMIT 10000")
#=> [{ "Id" => "00528000001lckgAAA", "Name" => "Salesforce.com, Inc." }, { "Id" => "75028000000oEcVAAU", "Name" => "GitHub, Inc." }]

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naoki-watanabe/seiun. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
