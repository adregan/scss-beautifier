class SCSSBeautifier::Formatter::StringQuotes < Sass::Tree::Visitors::Base
  def visit_prop(node)
    check_quotes(node)
    visit_children(node)
  end
  def check_quotes(node)
    return unless node.value.is_a?(Sass::Script::Tree::Literal)

    # TODO Check for single or double quote preference
    str_without_quotes = extract_string_without_quotes(node.value.value.to_s)
    change_to_single_quotes(node) if str_without_quotes && !str_without_quotes.match(/'/)
  end

  private

  STRING_WITHOUT_QUOTES_REGEX = %r{
    \A
    ["'](.*)["']    # Extract text between quotes
    \s*\)?\s*;?\s*  # Sometimes the Sass parser includes a trailing ) or ;
    (//.*)?         # Exclude any trailing comments that might have snuck in
    \z
  }x

  def change_to_single_quotes(node)
    new_val = node.value.value.to_s.gsub('"', '\'')
    node.instance_variable_set(:@value, Sass::Script::Value::String.new(new_val))
  end

  def extract_string_without_quotes(source)
    return unless match = STRING_WITHOUT_QUOTES_REGEX.match(source)
    match[1]
  end
end
