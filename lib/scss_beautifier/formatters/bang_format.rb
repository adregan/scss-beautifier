class SCSSBeautifier::Formatters::BangFormat < Sass::Tree::Visitors::Base
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
