require File.dirname(__FILE__) + '/helper'

class UnlessElseTest < Test::Unit::TestCase
  include Liquid

  def test_unless
    assert_template_result('  ',' {% unless true %} this text should not go into the output {% endunless %} ')
    assert_template_result('  this text should go into the output  ',
              ' {% unless false %} this text should go into the output {% endunless %} ')
    assert_template_result('  you rock ?','{% unless true %} you suck {% endunless %} {% unless false %} you rock {% endunless %}?')
  end

  def test_unless_else
    assert_template_result(' YES ','{% unless true %} NO {% else %} YES {% endunless %}')
    assert_template_result(' YES ','{% unless false %} YES {% else %} NO {% endunless %}')
    assert_template_result(' YES ','{% unless "foo" %} NO {% else %} YES {% endunless %}')
  end

end