#!/usr/bin/env ruby

$:.unshift "/Users/joenatalzia/Sites/tools/sass/lib"
require 'sass'
require_relative './lib/scss_beautify_convert'
contents = File.read(ARGV.first)
engine = Sass::Engine.new(contents, cache: false, syntax: :scss )

PSEUDO_ELEMENTS = File.read('./data/pseudo_elements.txt').split("\n")

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

class Sass::Tree::Visitors::NameFormat < Sass::Tree::Visitors::Base
  def visit_function(node)
    check_name(node)
  end

  def visit_mixin(node)
    check_name(node)
  end

  def visit_placeholder(node)
    check_name(node)
  end

  def visit_mixindef(node)
    check_name(node)
  end

  def visit_script_funcall(node)
    check_name(node)
  end

  def visit_script_variable(node)
    check_name(node)
  end

  def visit_variable(node)
    check_name(node)
  end

  def visit_rule(node)
    check_rule(node)
  end

  private

  def check_name(node)
    # return unless node.name
    node.instance_variable_set(:@name, Sass::Script::Value::String.new(node.name.to_s.gsub(/[[:upper:]]/) { "-#{$&}" }.downcase.gsub(/_/, '-')))
  end

  def check_rule(node)
    node.rule = Sass::Util.strip_string_array(node.rule.map { |r| r.to_s.gsub(/[[:upper:]]/) { "-#{$&}" }.downcase.gsub(/_/, '-') })
    node.send(:try_to_parse_non_interpolated_rules)
  end
end

class Sass::Tree::Visitors::PropertySortOrder < Sass::Tree::Visitors::Base
  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    prop_node_indices = []
    prop_nodes = []
    node.children.each_with_index do |child, index|
      hash_key = child.class.to_s.split("::").last
      if hash_key == 'PropNode'
        prop_node_indices << index
        prop_nodes << child
      end
    end
    prop_nodes.sort! { |x,y| x.name[0] <=> y.name[0] }
    # Replace children being respective of other types of props/funcs/etc
    prop_nodes.each_with_index do |n, index|
      node.children[prop_node_indices[index]] = n
    end
  end
end

class Sass::Tree::Visitors::PseudoElement < Sass::Tree::Visitors::Base
  def visit_rule(node)
    check_pseudo(node) if node.rule.join.match(/::?/)
    visit_children(node)
  end

  def check_pseudo(node)
    node.rule = Sass::Util.strip_string_array(node.rule.map { |r|
      require_double_colon = PSEUDO_ELEMENTS.index(r.split(":").last)

      colon_type = require_double_colon ? '::' : ':'

      r.gsub(/::?/, colon_type)
    })

    node.send(:try_to_parse_non_interpolated_rules)
  end
end

class Sass::Tree::Visitors::QualifyingElement < Sass::Tree::Visitors::Base
  def visit_rule(node)
    check_qualifying_element(node)
    visit_children(node)
  end

  def check_qualifying_element(node)
    node.rule.each do |r|
      puts r

      # node.send(:try_to_parse_non_interpolated_rules)
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
# Sass::Tree::Visitors::LeadingZero.visit(tree)
# Sass::Tree::Visitors::NameFormat.visit(tree)
# Sass::Tree::Visitors::PropertySortOrder.visit(tree)
Sass::Tree::Visitors::PseudoElement.visit(tree)
# Sass::Tree::Visitors::QualifyingElement.visit(tree)

puts SCSSBeautifyConvert.visit(tree, {}, :scss)
