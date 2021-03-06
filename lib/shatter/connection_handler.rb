module Shatter
  module ConnectionHandler
    def retrieve_connection(klass)
      if klass.respond_to?(:shattered?) && klass.shattered?
        if Thread.current[:shard_connection].present?
          return Thread.current[:shard_connection]
        end
      end

      pool = retrieve_connection_pool(klass)
      (pool && pool.connection) or raise ActiveRecord::ConnectionNotEstablished
    end
  end
end
