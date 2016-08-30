require 'test_helper'

class ScssBeautifierTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SCSSBeautifier::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_border_zero
    assert test_style_rule(SCSSBeautifier::Formatters::BorderZero, 'border_zero')
  end

  def test_color
    assert test_style_rule(SCSSBeautifier::Formatters::Color, 'color_keyword')
    assert test_style_rule(SCSSBeautifier::Formatters::Color, 'color_short')
  end
end
