$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'scss_beautifier'

require 'minitest/autorun'

def test_style_rule(formatter, test_file)
  old_contents = File.readlines("test/example_scss/#{test_file}.scss").join
  expected_contents = File.readlines("test/example_scss/beautified/#{test_file}.scss").join.strip
  engine = Sass::Engine.new(old_contents, cache: false, syntax: :scss)
  tree = engine.to_tree
  formatter.visit tree
  expected_contents == tree.to_scss.strip
end
