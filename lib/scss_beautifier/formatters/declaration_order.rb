class SCSSBeautifier::Formatters::DeclarationOrder < SCSSBeautifier::Formatters::Base

  DEFAULT_SORT_ORDER = ["mixindef", "extend", "mixin", "prop", "rule"].freeze

  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    node_hash = Hash.new { |h, k| h[k] = [] }
    comment_array = []
    node.children.each do |child|
      hash_key = child.class.node_name.to_s
      if hash_key == 'comment'
        comment_array << child
      else
        if comment_array.any?
          node_hash[hash_key] = node_hash[hash_key].concat comment_array
          comment_array = []
        end
        node_hash[hash_key] << child
      end
    end

    # add remaining comments
    node_hash['comment'] = comment_array if comment_array.any?

    compiled_array = sort_order.reduce([]) do |memo, key|
      memo.concat(node_hash[key])
    end

    (node_hash.keys - sort_order).reduce(compiled_array) do |memo, key|
      memo.concat(node_hash[key])
    end

    node.children = compiled_array
  end

  private

  def sort_order
    @sort_order ||= options["sort_order"] || DEFAULT_SORT_ORDER
  end
end
