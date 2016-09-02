class SCSSBeautifier::Formatters::Color < SCSSBeautifier::Formatters::Base
  def visit_prop(node)
    if node.value.respond_to?(:each)
      node.value.each{ |item| format_color(item) }
    else
      format_color(node.value)
    end
  end

  def format_color(item)
    if Sass::Script::Tree::Literal === item && Sass::Script::Value::String === item.value
      if color = Sass::Script::Value::Color::COLOR_NAMES[item.value.value]
        color_value = Sass::Script::Value::Color.new(color)
        color_value.options = {}
        item.instance_variable_set(:@value, Sass::Script::Value::String.new(color_value.inspect))
      elsif matches = item.value.value.match(/([\w\W]*)(#\h{3})(?!\h)([\w\W]*)/)
        str_start = matches[1]
        str_end = matches[3]
        hex = matches[2]
        long_form = [hex[0..1], hex[1], hex[2], hex[2], hex[3], hex[3]].join
        item.instance_variable_set(:@value, Sass::Script::Value::String.new(str_start + long_form + str_end))
      end
    end
  end

end
