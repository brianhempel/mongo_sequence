# MongoSequence

MongoSequence provides light-weight, robust sequences in MongoDB. They are useful for auto-incrementing or counting.  Compatible with any Mongo ODM.

MongoSequence creates named sequences in a "sequences" collection in your database and atomically increments and returns the counter on them using Mongo's findAndModify command. You won't have collisions—two processes trying to increment at the same time will alway get different numbers.

## Usage

Install with [Bundler](http://gembundler.com/):

``` ruby
gem "mongo_sequence"
```

Install without Bundler:

    gem install mongo_sequence --no-ri --no-rdoc

If you're _not_ using MongoMapper or Mongoid, you'll have to tell MongoSequence what database to use:

``` ruby
MongoSequence.database = Mongo::Connection.new.db('my_app_development')
```

Now, increment some sequences:

``` ruby
MongoSequence[:global].next    # => 1
MongoSequence[:global].next    # => 2

# get the current value...
# no guarantees of course on how long it's valid
# usually you use the return value of #next
MongoSequence[:global].current # => 2

# can also reset sequences if you need to
MongoSequence[:global] = 100
MongoSequence[:global].next    # => 101

# sequences with different names are independent
MongoSequence[:bluejay].next   # => 1
MongoSequence[:bluejay].next   # => 2
```

Here's how the sequences look in Mongo:

``` ruby
MongoSequence.collection.find_one(:_id => 'bluejay')
# =>
# {
#   "_id"     => "bluejay",
#   "current" => 2
# }
```

## Why?

Why would anyone need atomically incrementing sequences with unique return values? Well, the most common case is for auto-incrementing id's in Mongo. Here's a MongoMapper example:

``` ruby
class Peregrine
  include MongoMapper::Document
  key :_id, Integer, :default => lambda { nil }

  before_create do
    self.id ||= MongoSequence[:peregrine_id].next # for id's unique among Peregrines
    # or
    self.id ||= MongoSequence[:mongo_id].next     # for id's unique across the database
  end
end
```

## Help make it better!

Need something added? Please [open an issue](https://github.com/brianhempel/mongo_sequence/issues)! Or, even better, code it yourself and send a pull request:

    # fork it on github, then clone:
    git clone git@github.com:your_username/mongo_sequence.git
    bundle install
    rspec
    # hack away
    git push
    # then make a pull request

## License

Authored by Brian Hempel. Public domain, no restrictions.
