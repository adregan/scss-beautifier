class SCSSBeautifier::Formatters::PropertySortOrder < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    prop_nodes = []
    comment_array = []
    seen_comments = []
    node.children.each do |child|
      hash_key = child.class.node_name.to_s
      if hash_key == 'comment'
        seen_comments << child
        comment_array << child
      elsif hash_key == 'prop'
        prop_nodes << comment_array.push(child)
        comment_array = []
      end
    end

    # account for remaining comments
    seen_comments -= comment_array

    prop_nodes.sort! { |x,y| x.last.name[0] <=> y.last.name[0] }
    # Replace children being respective of other types of props/funcs/etc
    children = []
    node.children.each do |child|
      hash_key = child.class.node_name.to_s
      if hash_key == 'prop'
        children.concat(prop_nodes.shift)
      elsif hash_key != 'comment' || !seen_comments.include?(child)
        children << child
      end
    end
    node.children = children
  end
end
