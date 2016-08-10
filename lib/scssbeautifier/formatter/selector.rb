class SCSSBeautifier::Formatter::Selector < Sass::Tree::Visitors::Base
  def visit_rule(node)
    node.rule = node.rule.each do |rule|
      rule.gsub!(/,/, ",\n")
    end
    node.send(:try_to_parse_non_interpolated_rules)
  end
end
