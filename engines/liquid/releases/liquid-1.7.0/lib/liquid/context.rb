module Liquid
  
  class ContextError < StandardError
  end
  
  # Context keeps the variable stack and resolves variables, as well as keywords
  #
  #   context['variable'] = 'testing'
  #   context['variable'] #=> 'testing'
  #   context['true']     #=> true
  #   context['10.2232']  #=> 10.2232
  #   
  #   context.stack do 
  #      context['bob'] = 'bobsen'
  #   end
  #
  #   context['bob']  #=> nil  class Context
  class Context
    attr_reader :scopes
    attr_reader :template
    
    def initialize(template)
      @template   = template
      @scopes     = [template.assigns]
    end
           
    def strainer
      @strainer ||= Strainer.create(self)
    end
    
    def registers
      @template.registers
    end
               
    # adds filters to this context. 
    # this does not register the filters with the main Template object. see <tt>Template.register_filter</tt> 
    # for that
    def add_filters(filters)
      filters = [filters].flatten.compact
      
      raise ArgumentError, "Expected module but got: #{filter_module.class}" unless filters.all? { |f| f.is_a?(Module)}
      
      filters.each do |f|         
        strainer.extend(f)
      end      
    end
                              
    def invoke(method, *args)
      if strainer.respond_to?(method)
        strainer.__send__(method, *args)
      else
        args.first
      end        
    end

    # push new local scope on the stack. use <tt>Context#stack</tt> instead
    def push
      @scopes.unshift({})
    end
    
    # merge a hash of variables in the current local scope
    def merge(new_scopes)
      @scopes[0].merge!(new_scopes)
    end
  
    # pop from the stack. use <tt>Context#stack</tt> instead
    def pop
      raise ContextError if @scopes.size == 1 
      @scopes.shift
    end
    
    # pushes a new local scope on the stack, pops it at the end of the block
    #
    # Example:
    #
    #   context.stack do 
    #      context['var'] = 'hi'
    #   end
    #   context['var]  #=> nil
    #
    def stack(&block)
      result = nil
      push
      begin
        result = yield
      ensure 
        pop
      end
      result      
    end
  
    # Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    def []=(key, value)
      @scopes[0][key] = value
    end
  
    def [](key)
      resolve(key)
    end
  
    def has_key?(key)
      resolve(key) != nil
    end
        
    private
    
    # Look up variable, either resolve directly after considering the name. We can directly handle 
    # Strings, digits, floats and booleans (true,false). If no match is made we lookup the variable in the current scope and 
    # later move up to the parent blocks to see if we can resolve the variable somewhere up the tree.
    # Some special keywords return symbols. Those symbols are to be called on the rhs object in expressions
    #
    # Example: 
    #
    #   products == empty #=> products.empty?
    #
    def resolve(key)
      case key
      when nil
        nil
      when 'true'
        true
      when 'false'
        false
      when 'empty'
        :empty?
      when 'nil', 'null'
        nil
      # Single quoted strings
      when /^'(.*)'$/
        $1.to_s
      # Double quoted strings
      when /^"(.*)"$/
        $1.to_s        
      # Integer and floats
      when /^(\d+)$/ 
        $1.to_i
      when /^(\d[\d\.]+)$/ 
        $1.to_f
      else
        variable(key)
      end
    end
    
    # fetches an object starting at the local scope and then moving up 
    # the hierachy 
    def find_variable(key)
      @scopes.each do |scope|        
        if scope.has_key?(key)
          variable = scope[key] 
          variable = scope[key] = variable.call(self) if variable.is_a?(Proc)
          variable.context = self if variable.respond_to?(:context=)                          
          return variable
        end
      end
      nil
    end

    # resolves namespaced queries gracefully.
    # 
    # Example
    # 
    #  @context['hash'] = {"name" => 'tobi'}
    #  assert_equal 'tobi', @context['hash.name']
    #  assert_equal 'tobi', @context['hash[name]']
    #
    def variable(markup)
      parts   = markup.scan(VariableParser)      
      
      if object = find_variable(parts.shift).to_liquid
            
        parts.each do |part|        

          # If object is a hash we look for the presence of the key and if its available 
          # we return it

          # Hash
          if object.respond_to?(:has_key?) and object.has_key?(part)
          
            # if its a proc we will replace the entry in the hash table with the proc
            object[part] = object[part].call(self) if object[part].is_a?(Proc) and object.respond_to?(:[]=)
            object = object[part].to_liquid

          # Array
          elsif object.respond_to?(:fetch) and part =~ /^\d+$/ 
            pos = part.to_i

            object[pos] = object[pos].call(self) if object[pos].is_a?(Proc) and object.respond_to?(:[]=)
            object = object[pos].to_liquid
          
          # Some special cases. If no key with the same name was found we interpret following calls
          # as commands and call them on the current object
          elsif object.respond_to?(part) and ['size', 'first', 'last'].include?(part)
          
            object = object.send(part.intern).to_liquid
        
          # No key was present with the desired value and it wasn't one of the directly supported
          # keywords either. The only thing we got left is to return nil
          else
            return nil
          end
                
          # If we are dealing with a drop here we have to         
          object.context = self if object.respond_to?(:context=)
        end
      end
            
      object
    end                                       
    
    private
    
    def execute_proc(proc)
      proc.call(self)
    end
  end
end
