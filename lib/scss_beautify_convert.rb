class SCSSBeautifyConvert < Sass::Tree::Visitors::Convert
  def visit_if(node, &block)
    if true
      visit_if_no_newline(node, &block)
    else
      super(node)
    end
  end

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

end
