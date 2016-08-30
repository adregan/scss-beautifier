module SCSSBeautifier
  class CLI
    DEFAULT = File.realpath(File.join(File.dirname(__FILE__), "..", "..", "data", "default_config.yml")).freeze
    # Takes an array of arguments
    # Returns exit code
    def run(args)
      contents = File.read(ARGV.first)
      engine = Sass::Engine.new(contents, cache: false, syntax: :scss)

      tree = engine.to_tree
      config = Config.new(DEFAULT)

      config.formatters.each do |formatter|
        formatter.visit(tree)
      end

      puts SCSSBeautifier::Convert.visit(tree, {indent: config.tab_style}, :scss)

    end

  end
end
