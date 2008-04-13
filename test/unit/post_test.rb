require File.dirname(__FILE__) + '/../test_helper'

class PostTest < ActiveSupport::TestCase

  context "Post" do
    
    setup do
      @post = Post.new
    end
    
    should "be an ActiveRecord" do
      assert_kind_of ActiveRecord::Base, @post
    end
    
  end

end
