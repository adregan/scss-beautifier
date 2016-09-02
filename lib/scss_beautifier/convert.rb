class SCSSBeautifier::Convert < Sass::Tree::Visitors::Convert
  def visit_if(node, &block)
    if true
      visit_if_no_newline(node, &block)
    else
      super(node)
    end
  end
  # ElsePlacement
  def visit_if_no_newline(node)
    name =
      if !@is_else
        "if"
      elsif node.expr
        "else if"
      else
        "else"
      end
    @is_else = false
    str = "#{tab_str}@#{name}"
    str << " #{node.expr.to_sass(@options)}" if node.expr
    str << yield
    str.rstrip! if node.else
    @is_else = true
    str << ' ' + visit(node.else).lstrip! if node.else
    str
  ensure
    @is_else = false
  end

  # Visit rule-level nodes and return their conversion with appropriate
  # whitespace added.
  def visit_rule_level(nodes)
    Sass::Util.enum_cons(nodes + [nil], 2).map do |child, nxt|
      child_value = visit(child)
      spacing = if nxt &&
            (child.is_a?(Sass::Tree::CommentNode) && child.line + child.lines + 1 == nxt.line) ||
            (child.is_a?(Sass::Tree::ImportNode) && nxt.is_a?(Sass::Tree::ImportNode) &&
              child.line + 1 == nxt.line) ||
            (child.is_a?(Sass::Tree::VariableNode) && nxt.is_a?(Sass::Tree::VariableNode) &&
              child.line + 1 == nxt.line) ||
            (child.is_a?(Sass::Tree::PropNode) && nxt.is_a?(Sass::Tree::PropNode)) ||
            (child.is_a?(Sass::Tree::MixinNode) && nxt.is_a?(Sass::Tree::MixinNode) &&
              child.line + 1 == nxt.line)
          ""
        else
          if (child.is_a?(Sass::Tree::MixinNode) && nxt.is_a?(Sass::Tree::MixinNode)) ||
            (child.is_a?(Sass::Tree::ExtendNode) && nxt.is_a?(Sass::Tree::ExtendNode)) ||
            (child.is_a?(Sass::Tree::MixinNode) && child.children.any?)
            ""
          else
            "\n"
          end
        end
      if inline_comment?(child, nxt)
        child_value.rstrip!
        spacing = ""
        nxt.scss_beautifier_options[:inline] = true
      elsif child.scss_beautifier_options[:inline]
        spacing = ""
      end
      child_value + spacing
    end.join.rstrip + "\n"
  end

  def visit_comment(node)
    value = super
    node.scss_beautifier_options[:inline] ? ' ' + value.lstrip! : value
  end

  def inline_comment?(node, comment_node)
    comment_node.is_a?(Sass::Tree::CommentNode) && node.line == comment_node.line
  end

end
