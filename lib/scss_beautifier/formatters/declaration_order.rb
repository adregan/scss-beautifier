class SCSSBeautifier::Formatters::DeclarationOrder < Sass::Tree::Visitors::Base
  # TODO: Account for if/else blocks and include blocks
  NODE_ORDER = ["ExtendNode", "MixinNode", "PropNode", "RuleNode"]

  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    node_hash = Hash.new { |h, k| h[k] = [] }
    node.children.each do |child|
      hash_key = child.class.to_s.split("::").last
      node_hash[hash_key] << child
    end

    compiled_array = NODE_ORDER.reduce([]) do |memo, key|
      memo.concat(node_hash[key])
    end

    node.children = compiled_array
  end
end
