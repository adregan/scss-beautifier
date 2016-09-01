class SCSSBeautifier::Formatters::TrailingZero < SCSSBeautifier::Formatters::Base
  def visit_prop(node)
    check_trailing_zero(node)
    visit_children(node)
  end

  private

  FRACTIONAL_DIGIT_REGEX = /^-?(\d*\.\d+[a-zA-Z]*)/

  def check_trailing_zero(node)
    return unless number = node.value.to_s[FRACTIONAL_DIGIT_REGEX, 1]

    return unless match = /^(\d*\.(?:[0-9]*[1-9]|[1-9])*)0+([a-zA-Z]*)$/.match(number)

    fixed_number = match[1]
    extension = match[2]

    # Handle special case of 0 being the only trailing digit
    fixed_number = fixed_number[0..-2] if fixed_number.end_with?('.')
    fixed_number = 0 if fixed_number.empty? # Handle ".0" -> "0"
    node.instance_variable_set(:@value, Sass::Script::Value::String.new(fixed_number + extension))
  end
end
