class SCSSBeautifier::Formatter::Comment < Sass::Tree::Visitors::Base
  def visit_comment(node)
    # require 'pry'; binding.pry
    format_comment(node)# if !node.invisible?
  end

  def format_comment(node)
    node.value.first.gsub!(/\/\*\s?/, "// ")
    node.value.last.gsub!(/\*\//, "")
    # require 'pry'; binding.pry
    node.value.each do |item|
      if String === item
        item.gsub!(/\n\s?/, "\n// ")
      end
    end
  end
end
