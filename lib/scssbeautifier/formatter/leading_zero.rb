class SCSSBeautifier::Formatter::LeadingZero < Sass::Tree::Visitors::Base
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
