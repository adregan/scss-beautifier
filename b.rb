#!/usr/bin/env ruby

$:.unshift "/Users/joenatalzia/Sites/tools/sass/lib"
require 'sass'
require_relative './lib/scss_beautify_convert'
contents = File.read(ARGV.first)
engine = Sass::Engine.new(contents, cache: false, syntax: :scss )

class Sass::Tree::Visitors::PropertyOrder < Sass::Tree::Visitors::Base
  def visit_rule(node)
    grouped_children = node.children.group_by do |n|
      n.class.name.include?('PropNode') ? 'props' : 'other'
    end
    Array(grouped_children["props"]).each do |p|
      p.resolved_name = p.name.join
    end
    grouped_children["props"] = Array(grouped_children["props"]).sort_by {|p| p.resolved_name }
    node.children = Array(grouped_children["props"]) + Array(grouped_children["other"])
    yield
  end
end

class Sass::Tree::Visitors::BangFormat < Sass::Tree::Visitors::Base
  # def visit_extend(node)
  #   format_bang(node)
  # end

  def visit_prop(node)
    node.value.each{ |item| format_bang(item) }
  end

  # def visit_variable(node)
  #   format_bang(node)
  # end

  def format_bang(item)
    if Sass::Script::Tree::Literal === item && Sass::Script::Value::String === item.value
      if item.value.value.include?("!")
        item.instance_variable_set(:@value, Sass::Script::Value::String.new(item.value.value.gsub(/\s*!\s*/, ' !')))
      end
    end
  end
end

class Sass::Tree::Visitors::BorderZero < Sass::Tree::Visitors::Base
  BORDER_PROPERTIES = %w[
    border
    border-top
    border-right
    border-bottom
    border-left
  ].freeze


  def visit_prop(node)
    return unless BORDER_PROPERTIES.include?(node.name.first.to_s)
    # return unless node.value.length == 1
    format_border(node.value.first)
  end

  def format_border(node)
    return unless Sass::Script::Tree::Literal === node
    return unless node.value.value == "0"
    node.instance_variable_set(:@value, Sass::Script::Value::String.new("none"))
  end
end

class Sass::Tree::Visitors::Comment < Sass::Tree::Visitors::Base
  def visit_comment(node)
    # require 'pry'; binding.pry
    format_comment(node)# if !node.invisible?
  end

  def format_comment(node)
    node.value.first.gsub!(/\/\*\s?/, "// ")
    node.value.last.gsub!(/\*\//, "")
    # require 'pry'; binding.pry
    node.value.each do |item|
      if String === item
        item.gsub!(/\n\s?/, "\n// ")
      end
    end
  end
end


class Sass::Tree::Visitors::Color < Sass::Tree::Visitors::Base
  def visit_prop(node)
    node.value.each{ |item| format_color(item) }
  end

  def format_color(item)
    if Sass::Script::Tree::Literal === item && Sass::Script::Value::String === item.value
      if color = Sass::Script::Value::Color::COLOR_NAMES[item.value.value]
        color_value = Sass::Script::Value::Color.new(color)
        color_value.options = {}
        item.instance_variable_set(:@value, Sass::Script::Value::String.new(color_value.inspect))
      elsif item.value.value =~ /(#\h{3})(?!\h)/
        hex = item.value.value
        long_form = [hex[0..1], hex[1], hex[2], hex[2], hex[3], hex[3]].join
        item.instance_variable_set(:@value, Sass::Script::Value::String.new(long_form))
      end
    end
  end

end

class Sass::Tree::Visitors::Debug < Sass::Tree::Visitors::Base
  def visit_rule(node)
    filtered = node.children.reject do |c|
      Sass::Tree::DebugNode === c
    end
    node.children = filtered
  end
end

class Sass::Tree::Visitors::EmptyRule < Sass::Tree::Visitors::Base
  def visit_root(node)
    remove_empty_rule(node)
    yield
    remove_empty_rule(node)
  end
  def visit_rule(node)
    remove_empty_rule(node)
    visit_children(node)
    remove_empty_rule(node)
  end

  def remove_empty_rule(node)
    filtered = node.children.reject do |c|
      Sass::Tree::RuleNode === c && c.children.empty?
    end
    node.children = filtered
  end
end
class Sass::Tree::Visitors::Selector < Sass::Tree::Visitors::Base
  def visit_rule(node)
    node.rule = node.rule.each do |rule|
      rule.gsub!(/,/, ",\n")
    end
    node.send(:try_to_parse_non_interpolated_rules)
  end
end

class Sass::Tree::Visitors::DeclarationOrder < Sass::Tree::Visitors::Base
  # TODO: Account for if/else blocks and include blocks
  NODE_ORDER = ["ExtendNode", "MixinNode", "PropNode", "RuleNode"]

  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    node_hash = Hash.new { |h, k| h[k] = [] }
    node.children.each do |child|
      hash_key = child.class.to_s.split("::").last
      node_hash[hash_key] << child
    end

    compiled_array = NODE_ORDER.reduce([]) do |memo, key|
      memo.concat(node_hash[key])
    end

    node.children = compiled_array
  end
end

class Sass::Tree::Visitors::LeadingZero < Sass::Tree::Visitors::Base
  # ExcludeZero Only
  def visit_prop(node)
    if Sass::Script::Tree::Literal === node.value && Sass::Script::Value::String === node.value.value
      node_value = node.value.value

      if node.value.value.to_s.match(/\b0./)
        node.instance_variable_set(:@value, Sass::Script::Value::String.new(node.value.value.to_s.gsub(/\b0/, '')))
      end
    end
  end
end

# auto does
# SingleLinePerProperty
# SpaceAfterComma
# SpaceAfterPropertyColon
# SpaceAfterPropertyName
# SpaceAfterVariableColon
# SpaceAfterVariableName
# SpaceBeforeBrace
# SpaceBetweenParens
# TrailingSemicolon
# TrailingWhitespace ?

tree = engine.to_tree
# Sass::Tree::Visitors::PropertyOrder.visit(tree)
# Sass::Tree::Visitors::BangFormat.visit(tree)
# Sass::Tree::Visitors::BorderZero.visit(tree)
# Sass::Tree::Visitors::Comment.visit(tree)
# Sass::Tree::Visitors::Color.visit(tree)
# Sass::Tree::Visitors::Debug.visit(tree)
# Sass::Tree::Visitors::EmptyRule.visit(tree)
# Sass::Tree::Visitors::Selector.visit(tree)
# Sass::Tree::Visitors::DeclarationOrder.visit(tree)
# Sass::Tree::Visitors::ElsePlacement.visit(tree)
Sass::Tree::Visitors::LeadingZero.visit(tree)
puts SCSSBeautifyConvert.visit(tree, {}, :scss)
