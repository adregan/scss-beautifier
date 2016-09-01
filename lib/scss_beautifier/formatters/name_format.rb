class SCSSBeautifier::Formatters::NameFormat < SCSSBeautifier::Formatters::Base

  NODES_WITH_NAME = [
    :function,
    :mixin,
    :placeholder,
    :mixindef,
    :script_funcall,
    :script_variable,
    :variable
  ].freeze

  NODES_WITH_NAME.each do |type|
    define_method "visit_#{type}" do |node|
      return if disable_for.include?(type.to_s)
      check_name(node)
    end
  end

  def visit_rule(node)
    return if disable_for.include?("rule")
    check_rule(node)
  end

  private

  def disable_for
    @disable_for ||= @options["disable_for"] || []
  end

  def check_name(node)
    node.instance_variable_set(:@name, Sass::Script::Value::String.new(node.name.to_s.gsub(/[[:upper:]]/) { "-#{$&}" }.downcase.gsub(/(?<!_)_(?!_)/, '-')))
  end

  def check_rule(node)
    node.rule = Sass::Util.strip_string_array(node.rule.map { |r| r.to_s.gsub(/[[:upper:]]/) { "-#{$&}" }.downcase.gsub(/(?<!_)_(?!_)/, '-') })
    node.send(:try_to_parse_non_interpolated_rules)
  end
end
