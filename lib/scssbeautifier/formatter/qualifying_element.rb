class SCSSBeautifier::Formatter::QualifyingElement < Sass::Tree::Visitors::Base
  def visit_rule(node)
    check_qualifying_element(node)
    visit_children(node)
  end

  def check_qualifying_element(node)
    node.rule.each do |r|
      # What do we do when something breaks this rule?
    end

    node.send(:try_to_parse_non_interpolated_rules)
  end
end
