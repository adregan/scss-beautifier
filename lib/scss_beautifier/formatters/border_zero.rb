class SCSSBeautifier::Formatters::BorderZero < Sass::Tree::Visitors::Base
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
    format_border(node.value)
  end

  def format_border(node)
    return unless Sass::Script::Tree::Literal === node
    return unless node.value.value == "0"
    node.instance_variable_set(:@value, Sass::Script::Value::String.new("none"))
  end
end
