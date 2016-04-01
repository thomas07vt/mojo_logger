# MojoLogger

This gem is a wrapper around log4j and is primarily meant to be used in the Mojo framework. It will standardize logs accross Mojo applications and provide a single location to edit the Mojo Logger code base. It comes with a few benefits:

* **JSON** Logs will be printed for nice splunk logging when the mojo_* methods are called.
* No need for a log4j.properties file (although you can use one if you prefer). You can configure the logger on the fly and this gem will build a StringIO object to mock the log4j.properties file

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mojo_logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mojo_logger

## Usage

#### Simple access to a CONSOLE appender:

```ruby
require 'mojo_logger'

MojoLogger.debug "This is a message"
#=> This is a message

```

#### Mojo Formatted JSON logs
```ruby
require 'mojo_logger'

api_request = {
    session_id: '111111-11111',
    reference_id: 'client',
    api: 'get-user-info'
}

MojoLogger.mojo_warn(api_request, "Oops", "Some Warn Message")
#=> {"time":"08-25-2015 19:22:59.940 +0000","app":"Mojo","session_id":"111111-11111","reference_id":"client","api":"get-user-info","category":"Oops","message":"Some Warn Message"}

```

#### Mojo Formatted JSON logs with cusom keys
```ruby
require 'mojo_logger'

api_request = {
    session_id: '111111-11111',
    reference_id: 'client',
    api: 'get-user-info'
}

MojoLogger.mojo_warn(api_request, "Oops", "Some Warn Message", {my_key: "Some value", my_other_key: :another_val})
#=> {"time":"08-25-2015 19:24:57.575 +0000","app":"Mojo","session_id":"111111-11111","reference_id":"client","api":"get-user-info","category":"Oops","message":"Some Warn Message","my_key":"Some value","my_other_key":"another_val"} 

```


## Configuration

#### CONSOLE appender with "WARN" log level
```ruby
require 'mojo_logger'

MojoLogger.config do |config|
  config.default_log_level = :warn
end

MojoLogger.debug "This won't show up"
#=> nil

MojoLogger.warn "This will show up"
#=> This will show up

```


#### Rolling File appender
This will create a rolling file logger rather than a console logger with the following settings:
Max File Size = 10MB
Max Backup Index = 10
Pattern = '%n %m %n'  (I need to change this but this is what it is for now.)

```ruby
require 'mojo_logger'

MojoLogger.config do |config|
  config.log_file = '/var/log/my_log.log'
end

```

#### Add Custom lines to the generated log4j.properties 'file'

```ruby
require 'mojo_logger'

MojoLogger.config do |config|
  config.custom_line("log4j.logger.org.apache.zookeeper.ClientCnxn=INFO")
end

```

#### Add Custom adapter for format your logs
Add an adapter that will accept whatever fields you want to input and output a hash.
This hash will be converted to json by MojoLogger.

```ruby
require 'mojo_logger'

# by default you use the standard adapter

mojo_debug({}, 'category', 'this is my message', { custom: :field })
# =>

class CustomLogAdapter
  # an adapter must repond to #format() and return a Hash
  def format(application, message)
    {
      'application' => application,
      'message'     => message,
      'constant'    => 'Hello!'
    }
  end
end


MojoLogger.config do |config|
  config.adapter CustomLogAdapter.new
end

# now you can call the #mojo_* methods with the parameter you define

mojo_debug('application!', 'my message')
# =>

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mojo_logger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
