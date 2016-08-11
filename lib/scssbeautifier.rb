#!/usr/bin/env ruby

$:.unshift "/Users/joenatalzia/Sites/tools/sass/lib"

module SCSSBeautifier
  module Formatter
  end
end

require 'sass'
require_relative './scss_beautify_convert'
require_relative './scssbeautifier/formatter/bang_format'
require_relative './scssbeautifier/formatter/border_zero'
require_relative './scssbeautifier/formatter/color'
require_relative './scssbeautifier/formatter/comment'
require_relative './scssbeautifier/formatter/debug'
require_relative './scssbeautifier/formatter/declaration_order'
require_relative './scssbeautifier/formatter/empty_rule'
require_relative './scssbeautifier/formatter/leading_zero'
require_relative './scssbeautifier/formatter/name_format'
require_relative './scssbeautifier/formatter/property_sort_order'
require_relative './scssbeautifier/formatter/pseudo_element'
require_relative './scssbeautifier/formatter/qualifying_element'
require_relative './scssbeautifier/formatter/selector'
require_relative './scssbeautifier/formatter/shorthand'
require_relative './scssbeautifier/formatter/string_quotes'
require_relative './scssbeautifier/formatter/trailing_zero'

contents = File.read(ARGV.first)
engine = Sass::Engine.new(contents, cache: false, syntax: :scss )


tree = engine.to_tree
# SCSSBeautifier::Formatter::PropertyOrder.visit(tree)
# SCSSBeautifier::Formatter::BangFormat.visit(tree)
# SCSSBeautifier::Formatter::BorderZero.visit(tree)
# SCSSBeautifier::Formatter::Comment.visit(tree)
# SCSSBeautifier::Formatter::Color.visit(tree)
# SCSSBeautifier::Formatter::Debug.visit(tree)
# SCSSBeautifier::Formatter::EmptyRule.visit(tree)
# SCSSBeautifier::Formatter::Selector.visit(tree)
# SCSSBeautifier::Formatter::DeclarationOrder.visit(tree)
# SCSSBeautifier::Formatter::ElsePlacement.visit(tree)
# SCSSBeautifier::Formatter::LeadingZero.visit(tree)
# SCSSBeautifier::Formatter::NameFormat.visit(tree)
# SCSSBeautifier::Formatter::PropertySortOrder.visit(tree)
# SCSSBeautifier::Formatter::PseudoElement.visit(tree)
# SCSSBeautifier::Formatter::QualifyingElement.visit(tree)
# SCSSBeautifier::Formatter::Shorthand.visit(tree)
# SCSSBeautifier::Formatter::StringQuotes.visit(tree)
SCSSBeautifier::Formatter::TrailingZero.visit(tree)

puts SCSSBeautifyConvert.visit(tree, {}, :scss)
