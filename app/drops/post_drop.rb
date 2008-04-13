class PostDrop < Liquid::Drop
  
  def initialize(post)
    @post = post
  end
  
  def id
    @post.id
  end
  
  def title
    @post.title
  end
  
  def description
    @post.description
  end

end