class SCSSBeautifier::Formatters::Base < Sass::Tree::Visitors::Base

  attr_accessor :options

  def self.visit(root, options)
    new(options).send(:visit, root)
  end

  def initialize(options)
    @options = options
  end
end
