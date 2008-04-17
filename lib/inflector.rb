module Inflector
  
  def underscore
    self.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  def titleize
    self.underscore.humanize.gsub(/\b([a-z])/) { $1.capitalize }
  end
  
  def humanize
    self.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
  end
  
end

String.send(:include, Inflector)
