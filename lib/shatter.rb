require 'shatter/connection_handler'
require 'shatter/ar_extensions'

module Shatter
  def self.using_shard(config, &block)

    # shouldn't be one, but if there is, disconnect it.
    if conn = Thread.current[:shard_connection]
      conn.disconnect!
      Thread.current[:shard_connection] = nil
    end

    adapter_method = nil
    if config.respond_to? :has_key?
      adapter_method = config[:adapter].to_s + "_connection"
    else
      db_name = config
      config = ActiveRecord::Base.connection_config
      config[:database] = db_name
      adapter_method = config[:adapter].to_s + "_connection"
    end

    conn = ActiveRecord::Base.send(adapter_method, config)
    Thread.current[:shard_connection] = conn

    begin
      yield
    ensure
      conn.disconnect!
      Thread.current[:shard_connection] = nil
    end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::ConnectionAdapters::ConnectionHandler.send :include, Shatter::ConnectionHandler

  # but it's a singleton, and it's generally already been instantiated, so...
  ActiveRecord::Base.connection_handler.send :extend, Shatter::ConnectionHandler


  ActiveRecord::Base.send :class_attribute, :uses_sharding
  ActiveRecord::Base.send :extend, Shatter::ArExtensions
end
