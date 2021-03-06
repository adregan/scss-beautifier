#!/usr/bin/env ruby

module SCSSBeautifier
  module Formatters
  end
end

require "sass"

require "scss_beautifier/version"
require "scss_beautifier/cli"
require "scss_beautifier/options"
require "scss_beautifier/config"

# Our custom SCSS to SCSS converter
require "scss_beautifier/convert"

# Our base formatter
require "scss_beautifier/formatters/base"

# Formatters
require "scss_beautifier/formatters/border_zero"
require "scss_beautifier/formatters/color"
require "scss_beautifier/formatters/silent_comment"
require "scss_beautifier/formatters/debug"
require "scss_beautifier/formatters/declaration_order"
require "scss_beautifier/formatters/empty_rule"
require "scss_beautifier/formatters/leading_zero"
require "scss_beautifier/formatters/name_format"
require "scss_beautifier/formatters/property_sort_order"
require "scss_beautifier/formatters/pseudo_element"
require "scss_beautifier/formatters/qualifying_element"
require "scss_beautifier/formatters/selector"
require "scss_beautifier/formatters/shorthand"
require "scss_beautifier/formatters/string_quotes"
require "scss_beautifier/formatters/trailing_zero"

class Sass::Tree::Node
  attr_accessor :scss_beautifier_options

  def scss_beautifier_options
    @scss_beautifier_options ||= {}
  end

end
