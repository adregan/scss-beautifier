require "sinatra/base"
require "scss_beautifier"

class ScssBeautifierApp < Sinatra::Base

  get "/" do
    redirect '/index.html'
  end

  post "/beautify" do
    engine = Sass::Engine.new(request.body.read.to_s, cache: false, syntax: :scss)

    begin
      tree = engine.to_tree
    rescue Sass::SyntaxError => e
      return e.message
    end

    config = SCSSBeautifier::Config.new(SCSSBeautifier::CLI::DEFAULT)

    config.formatters.each do |formatter|
      formatter.send(:visit, tree)
    end

    output = SCSSBeautifier::Convert.visit(tree, {indent: config.tab_style}, :scss)

  end

end
