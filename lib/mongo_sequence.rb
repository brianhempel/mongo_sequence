require "mongo"

class MongoSequence

  class << self
    attr_accessor :database

    def collection
      database['sequences']
    end

    def [](name)
      sequences[name.to_sym] ||= new(name)
    end

    def []=(name, integer)
      self[name].current = integer
    end

    def sequences
      @sequences ||= {}
    end
  end

  attr_reader :name

  def initialize(name)
    @name = name.to_s
  end

  def collection
    MongoSequence.collection
  end

  def next
    current_after_operation(:$inc => { :current => 1 })
  end

  def current
    current_after_operation(:$set => {}) # noop that works
  end

  def current=(integer)
    current_after_operation(:current => integer)
  end

  private

  def current_after_operation(operation)
    collection.find_and_modify(
      :query  => { :_id => name },
      :new    => true, # return the modified doc
      :update => operation,
      :upsert => false
    )['current']
  rescue Mongo::OperationFailure => e
    raise unless e.message =~ /No matching object found/
    init_in_database
    current_after_operation(operation)
  end

  def init_in_database
    collection.save({:_id => name, :current => 0}, :safe => true)
  end
end