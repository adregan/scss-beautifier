class SCSSBeautifier::Formatters::PropertySortOrder < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    prop_node_indices = []
    prop_nodes = []
    node.children.each_with_index do |child, index|
      hash_key = child.class.to_s.split("::").last
      if hash_key == 'PropNode'
        prop_node_indices << index
        prop_nodes << child
      end
    end
    prop_nodes.sort! { |x,y| x.name[0] <=> y.name[0] }
    # Replace children being respective of other types of props/funcs/etc
    prop_nodes.each_with_index do |n, index|
      node.children[prop_node_indices[index]] = n
    end
  end
end
