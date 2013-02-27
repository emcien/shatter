# Shatter

Shatter is a database sharding tool, but not the kind you're used to.

### Motivation

Our application often consist of some business-level data, and then a set of 'reports',
compiled relational data, sizable in scope. Dozens of tables, with thousands or millions
of records in each for a single report.

Those reports create a natural sharding strategy for conventional database sharding,
where each report is allocated to some shard - this would essentially solve any
database scaling problems we might run into.. But our problems are not with database
power or reponse-time. Our unusual problems can instead be solved by treating each
report as a 'document' filled with relational data.

These documents can be sqlite3 databases, or separate dbs in our db server,
but they are in separate databases of some kind. ActiveRecord has facilities to allow
different models to use different connection-pools, what they call 'vertical sharding',
but no good way to have different *instances* of some models use different connections.

### Implementation

Shatter uses a thread-local variable to store a connection to the shard. You indicate
which objects should be sharded, and you provide overall logic to select a shard for
those objects (usually an around-filter in your ApplicationController).

Shatter hooks into the `ActiveRecord::Base.connection_handler` singleton, patching
the `retrieve_connection` method to check the class for `shattered?`, and use
`Thread.current[:shard_connection]` instead of a connection from the pool in that case.

## Usage

At the basic level, you can just call `self.shatter!` on the models that are going to
be sharded (a class method). Then you wrap requests with `Shatter.using_shard` to
indicate which shard should be used:

```ruby

class FooBar < ActiveRecord::Base
  self.shatter!
end


AppliationController < ActionController::Base

  around_filter :use_appropriate_shard

  def use_appropriate_shard
    if params[:report_id].present?
      Shatter.using_shard(shard_config) do
        yield
      end
    else
      yield
    end
  end
end
```

While inside the `using_shard` block, any request for `FooBar.connection` will return
the thread-local shard connection instead. Since ActiveRecord uses `connection`
internally in all the appropriate places so it can support vertical sharding,
this is sufficient to accomplish our goals.

`using_shard` accepts one parameter, a database configuration. It can either be
a hash, matching `ActiveRecord::Base.connection_config` in form, or it can be a
string, in which case the base config will be used, but with a different database name.

## Disadvantages

The big one is that the `using_shard` block has to build a new connection to the
database, and destroy is after completion. For these connections, we lose the
benefits inherent in ActiveRecord's 'connection pooling', which costs some performance,
particularly for very light requests. Connecting to the database is equivalent to
performing several light queries in a row, as it performs its handshakes.

The secondary disadvantage is that Shatter is built by monkey-patching ActiveRecord.
This means that a specific version of Shatter will require a specific version of
ActiveRecord (though that method hasn't seen a lot of churn). Also, it's kind of gross.

Lastly, because 'shardedness' is decided at the class level, there's no provision for
sharding only *some* of the instances of a given model. You can work around that
by sharding to the main database in `using_shard`, but you still don't get to use the
connection pool.
