class SCSSBeautifier::Formatters::DeclarationOrder < SCSSBeautifier::Formatters::Base
  def visit_rule(node)
    order_children(node)
    visit_children(node)
  end

  def order_children(node)
    # require 'pry'; binding.pry
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

    compiled_array = sort_order.reduce([]) do |memo, key|
      memo.concat(node_hash[key])
    end

    (node_hash.keys - sort_order).reduce(compiled_array) do |memo, key|
      memo.concat(node_hash[key])
    end

    node.children = compiled_array
  end

  def sort_order
    @sort_order ||= @options["sort_order"]
  end
end
