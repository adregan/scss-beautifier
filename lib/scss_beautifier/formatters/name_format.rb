class SCSSBeautifier::Formatters::NameFormat < Sass::Tree::Visitors::Base
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
    node.instance_variable_set(:@name, Sass::Script::Value::String.new(node.name.to_s.gsub(/[[:upper:]]/) { "-#{$&}" }.downcase.gsub(/(?<!_)_(?!_)/, '-')))
  end

  def check_rule(node)
    node.rule = Sass::Util.strip_string_array(node.rule.map { |r| r.to_s.gsub(/[[:upper:]]/) { "-#{$&}" }.downcase.gsub(/(?<!_)_(?!_)/, '-') })
    node.send(:try_to_parse_non_interpolated_rules)
  end
end
