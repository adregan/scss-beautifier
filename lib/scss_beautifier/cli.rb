module SCSSBeautifier
  class CLI
    DEFAULT = File.realpath(File.join(File.dirname(__FILE__), "..", "..", "data", "default_config.yml")).freeze
    # Takes an array of arguments
    # Returns exit code
    def run(args)
      options = Options.new.parse(args)

      contents = File.read(args.first)
      engine = Sass::Engine.new(contents, cache: false, syntax: :scss)

      tree = engine.to_tree
      config = Config.new(options[:config] || DEFAULT)

      config.formatters.each do |formatter|
        formatter.visit(tree)
      end

      output = SCSSBeautifier::Convert.visit(tree, {indent: config.tab_style}, :scss)
      if options[:in_place]
        File.write(args.first, output)
      else
        puts output
      end
    end

  end
end
