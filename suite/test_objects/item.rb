module TestObjects
  
  class Item
    
    @@incrementor   = 0
    
    attr_accessor   :name
    attr_reader     :position
    
    
    def self.collection_of(size)
      if size.respond_to?(:each)
        return size.collect { |count| Array.new(count) { self.new } }
      elsif size.is_a? Numeric
        return Array.new(size) { self.new }
      end
    end
    
    def initialize
      @name = new_name(rand(25) + 5)
      @position = (@@incrementor += 1)
    end
    
    def to_liquid
      ItemDrop.new self
    end
    
    
    private
    
    
    ##
    # Thanks to disguestingangel at http://snippets.dzone.com/posts/show/491
    # for posting this method.
    #
    def new_name(length)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      return Array.new(length) { chars[rand(chars.size)] }.join
    end
    
    
  end
  
end