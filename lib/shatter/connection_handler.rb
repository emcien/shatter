module Shatter
  module ConnectionHandler
    def retrieve_connection(klass)
      if klass.sharded?
        if Thread.current[:shard_connection].present?
          puts "Using sharded connection"
          return Thread.current[:shard_connection]
        else
          raise "Sharding requested, but no sharded connection found"
        end
      else
        puts "Sharding not requested"
      end

      pool = retrieve_connection_pool(klass)
      (pool && pool.connection) or raise ConnectionNotEstablished
    end
  end
end
