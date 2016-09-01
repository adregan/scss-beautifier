class SCSSBeautifier::Formatters::SilentComment < SCSSBeautifier::Formatters::Base
  def visit_comment(node)
    format_comment(node) if node.type == :normal
  end

  private

  def format_comment(node)
    # Remove /* from the beginning
    node.value.first.gsub!(/^\/\*/, "//")
    # Remove */ from the end
    node.value.last.gsub!(/\*\/$/, "")
    node.value.each do |item|
      item.gsub!(/\n/, "\n//") if String === item
    end
  end

end
