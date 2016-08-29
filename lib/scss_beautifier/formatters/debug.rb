class SCSSBeautifier::Formatters::Debug < Sass::Tree::Visitors::Base
  def visit_rule(node)
    filtered = node.children.reject do |c|
      Sass::Tree::DebugNode === c
    end
    node.children = filtered
  end
end
