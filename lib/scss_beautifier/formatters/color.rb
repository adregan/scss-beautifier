class SCSSBeautifier::Formatters::Color < SCSSBeautifier::Formatters::Base
  HEX_REGEX = /(#\h{3})(?!\h)/

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
      elsif item.value.value =~ HEX_REGEX

        new_val = item.value.value.split(" ").map do |val|
          val.match(HEX_REGEX) ? [val[0..1], val[1], val[2], val[2], val[3], val[3]].join : val
        end.join(" ")

        item.instance_variable_set(:@value, Sass::Script::Value::String.new(new_val))
      end
    end
  end

end
