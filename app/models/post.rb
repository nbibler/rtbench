class Post < ActiveRecord::Base
  
  def to_liquid
    PostDrop.new self
  end
  
end
