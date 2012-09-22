require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mongo_sequence'
require 'mongo_mapper'
require 'mongoid'

describe MongoSequence do
  before :each do
    MongoMapper.database   = nil
    # can't get rid of Mongoid's db :/
    MongoSequence.database = nil
  end

  context "no ODM" do
    before :each do
      @db = Mongo::Connection.new.db('mongo_sequence_test')
      @db.collections.each(&:remove)
      MongoSequence.database = @db
    end

    it "returns MongoSequence objects" do
      MongoSequence[:test].class.should == MongoSequence
    end

    it "starts at 1 for a new sequence" do
      MongoSequence[:test].next.should == 1
    end

    it "increments every time .next is called" do
      MongoSequence[:test].next
      MongoSequence[:test].next.should == 2
      MongoSequence[:test].next.should == 3
    end

    it "lets us get the current count" do
      MongoSequence[:test].current.should == 0
      MongoSequence[:test].next
      MongoSequence[:test].current.should == 1
      MongoSequence[:test].current.should == 1 # current should not increment
    end

    it "pulls current from the database" do
      MongoSequence[:test].current.should == 0
      @db['sequences'].update({ :_id => "test" }, { :current => 100 })
      MongoSequence[:test].current.should == 100
    end

    it "increments different sequences separately" do
      MongoSequence[:seq1].next
      MongoSequence[:seq1].next.should == 2
      MongoSequence[:seq2].next.should == 1
      MongoSequence[:seq2].next.should == 2
    end

    it "lets us set the current count" do
      MongoSequence[:test].current = 100
      MongoSequence[:test].current.should == 100
      MongoSequence[:test].next.should == 101
    end

    it "lets us set the current count with shorthand syntax" do
      MongoSequence[:test] = 100
      MongoSequence[:test].current.should == 100
      MongoSequence[:test].next.should == 101
    end

    it "accepts strings or symbols for the sequence name" do
      MongoSequence[:test] = 100
      MongoSequence['test'].current.should == 100
      MongoSequence['test'] = 200
      MongoSequence[:test].current.should == 200
    end

    it "uses the 'sequences' collection" do
      MongoSequence[:seq1].current
      MongoSequence[:seq2].current
      MongoSequence[:seq3].current
      @db['sequences'].count.should == 3
    end

    it "sets the _id to the sequence name" do
      MongoSequence[:foo].current
      @db['sequences'].find.first['_id'].should == "foo"
    end

    it "should actually use the database" do
      MongoSequence.collection.save(:_id => "test", :current => 200)
      MongoSequence[:test].current.should == 200
    end
  end

  context "MongoMapper" do
    before :each do
      MongoMapper.database = "mongo_sequence_test_mm"
    end

    it "uses MongoMapper's database by default" do
      MongoSequence.database.name.should == "mongo_sequence_test_mm"
    end

    it "allows overriding the database" do
      MongoSequence.database = Mongo::Connection.new.db('mongo_sequence_test')
      MongoSequence.database.name.should == "mongo_sequence_test"
    end

    it "starts at 1 for a new sequence and increments" do
      MongoSequence[:test].current = 0
      MongoSequence[:test].next.should == 1
      MongoSequence[:test].next.should == 2
    end

  end

  context "Mongoid" do
    before :each do
      Mongoid.config.from_hash('database' => "mongo_sequence_test_mongoid", 'logger' => false)
      # Mongoid.connect_to("mongo_sequence_test_mongoid") ## Mongoid 3
    end

    it "uses Mongoid's database by default" do
      MongoSequence.database.name.should == "mongo_sequence_test_mongoid"
      # Mongoid.sessions['default']['database'].should == "mongo_sequence_test_mongoid" # Mongoid 3
    end

    it "allows overriding the database" do
      ## TODO: Mongoid 3 uses Moped.  Need to refactor a bunch.
      MongoSequence.database = Mongo::Connection.new.db('mongo_sequence_test')
      MongoSequence.database.name.should == "mongo_sequence_test"
    end

    it "starts at 1 for a new sequence and increments" do
      MongoSequence[:test].current = 0
      MongoSequence[:test].next.should == 1
      MongoSequence[:test].next.should == 2
    end

  end
end