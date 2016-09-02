require "sinatra/base"
require "scss_beautifier"

class ScssBeautifierApp < Sinatra::Base

  post "/beautify" do
   engine = Sass::Engine.new(request.body.read.to_s, cache: false, syntax: :scss)

   tree = engine.to_tree
   config = SCSSBeautifier::Config.new(SCSSBeautifier::CLI::DEFAULT)

   config.formatters.each do |formatter|
     formatter.send(:visit, tree)
   end

   output = SCSSBeautifier::Convert.visit(tree, {indent: config.tab_style}, :scss)

  end

end
