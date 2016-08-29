class SCSSBeautifier::Formatters::EmptyRule < Sass::Tree::Visitors::Base
  def visit_root(node)
    remove_empty_rule(node)
    yield
    remove_empty_rule(node)
  end
  def visit_rule(node)
    remove_empty_rule(node)
    visit_children(node)
    remove_empty_rule(node)
  end

  def remove_empty_rule(node)
    filtered = node.children.reject do |c|
      Sass::Tree::RuleNode === c && c.children.empty?
    end
    node.children = filtered
  end
end
