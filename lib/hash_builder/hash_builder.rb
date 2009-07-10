module HashBuilderExtensions
  def with(key, *args)
    self.update(HashBuilder.build(key, *args))
  end 
end 

class Hash; include HashBuilderExtensions; end
class HashBuilderError < Exception; end

class HashBuilder

  class << self

    def define(key=nil)
      raise HashBuilderError, "You need to pass in a hash builder key (e.g., HashBuilder.define(:foo))" if key.nil?
#      raise HashBuilderError, "The hash builder key ':#{key}' is already being used." if builders[key.to_sym]

      builders[key.to_sym] = self.new
      yield builders[key.to_sym]
    end 

    def build(key=nil, *args)
      raise HashBuilderError, "You need to pass in a hash builder key (e.g., HashBuilder.build(:foo))" if key.nil?
      raise HashBuilderError, "Unable to find hash builder definition for key #{key}" unless (builder = builders[key.to_sym])

      yield builder if block_given?
      builder.call(*args)
    end 

    def build_namespace(key, namespace, *args)
      raise HashBuilderError, "Unable to find hash builder definition for key #{key}" unless (builder = builders[key.to_sym])
      builder.call_namespace(namespace.to_sym, *args)
    end 

    def builders
      @builders ||= {}
    end 

    def reset(*keys)
      keys.each do |key| 
        @builders[key.to_sym].builder_hash = {} if @builders[key.to_sym]
      end 
    end 

  end 

  attr_reader :hash_blocks
  attr_accessor :builder_hash

  def []=(key, value)
    hash[key] = value
  end

  def build_hash(key=nil, &block)
    @hash_blocks ||= {}
    if(key)
      @hash_blocks[key.to_sym] = block
    else
      @hash_blocks[:namespace] = block
    end 
  end 

  def call(*args)
    if(included_namespace_keys.size > 0)
      included_namespace_keys.each do |key|
        @hash_blocks[key].call(*args)
      end 
    else 
      @hash_blocks.each { |k,v| v.call(*args) }
    end 
    hash
  end 

  def call_namespace(key, *args)
    @hash_blocks[key].call(*args)
    hash
  end 

  def hash
    @builder_hash ||= Hash.new
  end

  def included_namespace_keys
    @included_namespace_keys ||= []
  end

  def using(key)
    included_namespace_keys << key unless included_namespace_keys.include?(key)
  end

end
