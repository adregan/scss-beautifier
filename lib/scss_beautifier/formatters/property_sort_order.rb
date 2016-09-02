class SCSSBeautifier::Formatters::PropertySortOrder < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  private

  def order_children(node)
    prop_nodes = []
    comment_array = []
    seen_comments = []
    node.children.each do |child|
      hash_key = child.class.node_name.to_s
      if hash_key == 'comment'
        seen_comments << child
        prev_grouping = prop_nodes.last
        if prop_node_for(prev_grouping).line == child.line
          prev_grouping << child
        else
          comment_array << child
        end
      elsif hash_key == 'prop'
        prop_nodes << comment_array.push(child)
        comment_array = []
      end
    end

    # account for remaining comments
    seen_comments -= comment_array

    prop_nodes.sort! { |x,y| prop_node_for(x).name[0] <=> prop_node_for(y).name[0] }
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

  # In an Array of nodes, get the prop node
  def prop_node_for(grouping)
    grouping.find { |node| node.class.node_name == :prop }
  end
end
