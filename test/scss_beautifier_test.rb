require 'test_helper'
require 'json'

class ScssBeautifierTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SCSSBeautifier::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_formatters
    formatter_list = JSON.parse(File.readlines("test/formatter_test_data.json").join)

    formatter_list.each do |f|
      f["files"].each do |file|
        assert test_style_rule(Object.const_get(f["formatter"]), file)
      end
    end
  end
end
