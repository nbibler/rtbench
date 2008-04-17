module Handlers
  
  class Radius < RTBench::Handler
    
    def self.execute(task, arguments = {})
      context = initialize_context(arguments)
      ::Radius::Parser.new(context, :tag_prefix => 'radius').parse(task.for(self))
    end
    
    
    private
    
    
    def self.initialize_context(arguments)
      ::Radius::Context.new do |c|
        c.define_tag 'item' do |tag|
          tag.locals.item = arguments['single_item']
          tag.expand
        end
        
        c.define_tag 'collection' do |tag|
          tag.locals.collection = arguments['item_pool']
          tag.expand
        end
        
        c.define_tag 'time' do |tag|
          tag.locals.time = arguments['time']
          tag.expand
        end
        
        c.define_tag 'name' do |tag|
          tag.locals.item.name
        end
        
        c.define_tag 'position' do |tag|
          tag.locals.item.position
        end
        
        c.define_tag 'format_time' do |tag|
          tag.locals.time.strftime(tag.attr['format'])
        end
        
        c.define_tag 'for_each' do |tag|
          content = ''
          tag.locals.collection.each do |collection_item|
            tag.locals.item = collection_item
            content << tag.expand
          end
          content
        end
        
        c.define_tag 'size' do |tag|
          tag.locals.collection.size
        end
        
      end
    end
    
  end
  
end
 
RTBench::Registrar.register_handler Handlers::Radius