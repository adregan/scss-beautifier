class SCSSBeautifier::Formatter::Shorthand < Sass::Tree::Visitors::Base
  def visit_prop(node)
    property_name = node.name.join
    return unless SHORTHANDABLE_PROPERTIES.include?(property_name)

    case node.value
    when Sass::Script::Tree::Literal
      update_script_literal(property_name, node)
    when Sass::Script::Tree::ListLiteral
      update_script_list(property_name, node)
    end
  end

  def update_script_literal(pName, node)
    nValue = node.value

    return unless values = nValue.value.to_s.strip[LIST_LITERAL_REGEX, 1]
    values = values.split(' ')

    check_shorthand(pName, node, values)
  end

  def update_script_list(pName, node)
    nValue = node.value

    check_shorthand(pName, node, nValue.children.map(&:to_sass), true)
  end

  private

  SHORTHANDABLE_PROPERTIES = %w[
    border-color
    border-radius
    border-style
    border-width
    margin
    padding
  ].freeze

  LIST_LITERAL_REGEX = /
    \A
    (\S+\s+\S+(\s+\S+){0,2})   # Two to four values separated by spaces
    (\s+!\w+)?                 # Ignore `!important` priority overrides
    \z
  /x

  def check_shorthand(prop, node, values)
    shortest_form = condensed_shorthand(*values)

    return if values == shortest_form

    node.instance_variable_set(:@value, Sass::Script::Value::String.new(shortest_form.join(' ')))
  end

  def allowed?(size)
    # return false unless config['allowed_shorthands']
    # config['allowed_shorthands'].map(&:to_i).include?(size)
    [1, 2, 3, 4].map(&:to_i).include?(size)
  end

  # @param top [String]
  # @param right [String]
  # @param bottom [String]
  # @param left [String]
  # @return [Array]
  def condensed_shorthand(top, right, bottom = nil, left = nil)
    if condense_to_one_value?(top, right, bottom, left)
      [top]
    elsif condense_to_two_values?(top, right, bottom, left)
      [top, right]
    elsif condense_to_three_values?(top, right, bottom, left)
      [top, right, bottom]
    else
      [top, right, bottom, left].compact
    end
  end

  # @param top [String]
  # @param right [String]
  # @param bottom [String]
  # @param left [String]
  # @return [Boolean]
  def condense_to_one_value?(top, right, bottom, left)
    return unless allowed?(1)
    return unless top == right

    top == bottom && (bottom == left || left.nil?) ||
      bottom.nil? && left.nil?
  end

  # @param top [String]
  # @param right [String]
  # @param bottom [String]
  # @param left [String]
  # @return [Boolean]
  def condense_to_two_values?(top, right, bottom, left)
    return unless allowed?(2)

    top == bottom && right == left ||
      top == bottom && left.nil? && top != right
  end

  # @param right [String]
  # @param left [String]
  # @return [Boolean]
  def condense_to_three_values?(_, right, __, left)
    return unless allowed?(3)

    right == left
  end

end
