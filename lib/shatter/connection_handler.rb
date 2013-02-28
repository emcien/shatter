module Shatter
  module ConnectionHandler
    def retrieve_connection(klass)
      if klass.shattered?
        if Thread.current[:shard_connection].present?
          return Thread.current[:shard_connection]
        else
          raise "Sharding requested, but no sharded connection found"
        end
      end

      pool = retrieve_connection_pool(klass)
      (pool && pool.connection) or raise ConnectionNotEstablished
    end
  end
end
