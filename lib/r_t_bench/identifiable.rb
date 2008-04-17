module RTBench
  
  module Identifiable
    
    def identifier
      self.to_s.split('::').last.underscore.to_sym
    end
  
  end
  
end