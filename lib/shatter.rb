require 'shatter/connection_handler'
require 'shatter/ar_extensions'

module Shatter
  def self.using_shard(config, parent = nil, &block)
    self.set_shard!(config, parent)
    begin
      yield
    ensure
      self.close_shard!
    end
  end

  def self.set_shard!(config, parent = nil)
    if conn = self.connection
      conn.disconnect!
      self.connection = nil
    end

    adapter_method = nil
    if config.nil?
      config = ActiveRecord::Base.connection_config.dup
      adapter_method = config[:adapter].to_s + "_connection"
    elsif config.respond_to? :has_key?
      adapter_method = config[:adapter].to_s + "_connection"
    else
      db_name = config
      config = ActiveRecord::Base.connection_config.dup
      config[:database] = db_name
      adapter_method = config[:adapter].to_s + "_connection"
    end

    self.parent = parent unless parent.nil?

    conn = ActiveRecord::Base.send(adapter_method, config)
    self.connection = conn
  end

  def self.close_shard!
    if self.connection
      self.connection.disconnect!
      self.connection = nil
    end
    self.parent = nil if self.parent
  end

  def self.parent
    Thread.current[:shard_parent] || nil
  end

  def self.parent=(val)
    Thread.current[:shard_parent] = val
  end

  def self.connection
    Thread.current[:shard_connection] || nil
  end

  def self.connection=(val)
    Thread.current[:shard_connection] = val
  end
end

if Object.const_defined?("ActiveRecord")
  # it's a singleton, and it's generally already been instantiated, so we need to extend the instance.
  ActiveRecord::Base.connection_handler.send :extend, Shatter::ConnectionHandler

  # This is probably unnecessary, but I don't know under what circumstances that instance might be re-created
  ActiveRecord::ConnectionAdapters::ConnectionHandler.send :include, Shatter::ConnectionHandler

  ActiveRecord::Base.send :class_attribute, :uses_sharding
  ActiveRecord::Base.send :extend, Shatter::ArExtensions
end
