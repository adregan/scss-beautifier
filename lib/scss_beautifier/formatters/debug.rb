class SCSSBeautifier::Formatters::Debug < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    filtered = node.children.reject do |c|
      Sass::Tree::DebugNode === c
    end
    node.children = filtered
  end
end
