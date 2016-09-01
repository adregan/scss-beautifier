class SCSSBeautifier::Formatters::Selector < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    node.rule = node.rule.each do |rule|
      rule.gsub!(/,/, ",\n") if rule.is_a?(String)
    end
    node.send(:try_to_parse_non_interpolated_rules)
  end
end
