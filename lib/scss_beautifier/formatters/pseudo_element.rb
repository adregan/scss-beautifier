PSEUDO_ELEMENTS = File.read(File.realpath(File.join(File.dirname(__FILE__), "..", "..", "..", "data", "pseudo_elements.txt"))).split("\n")

class SCSSBeautifier::Formatters::PseudoElement < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    check_pseudo(node) if node.rule.join.match(/::?/)
    visit_children(node)
  end

  def check_pseudo(node)
    node.rule = Sass::Util.strip_string_array(node.rule.map { |r|
      return r unless r.is_a?(String)
      require_double_colon = PSEUDO_ELEMENTS.index(r.split(":").last)

      colon_type = require_double_colon ? '::' : ':'

      r.gsub(/::?/, colon_type)
    })

    node.send(:try_to_parse_non_interpolated_rules)
  end
end
