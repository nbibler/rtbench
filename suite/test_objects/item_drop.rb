module TestObjects
  
  class ItemDrop < ::Liquid::Drop
    
    def initialize(item)
      @item = item
    end
    
    def name
      @item.name
    end
    
    def position
      @item.position
    end
    
  end
  
end