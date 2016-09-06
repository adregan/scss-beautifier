require "optparse"

module SCSSBeautifier
  class Options

    attr_reader :options

    def initialize
      @options = {}
      @option_parser = OptionParser.new do |opts|
        opts.version = SCSSBeautifier::VERSION
        add_banner(opts)
        add_config_option(opts)
        add_in_place_option(opts)
        add_generate_config_option(opts)
      end
    end

    def parse(args)
      @option_parser.parse!(args)
      options[:path] = args.first if args.first
      add_defaults
      options
    end

    private

    def add_defaults
      if File.exists?(".scss-beautifier") && options[:config].nil?
        options[:config] = ".scss-beautifier"
      end
    end

    def add_banner(opts)
      opts.banner = unindent(<<-BANNER)
        Beautify your SCSS code
        Usage: #{opts.program_name} [options] [path]
      BANNER
    end

    def add_config_option(opts)
      message = "the configuration file"
      opts.on("-c", "--config config", message, String) do |config|
        self.options[:config] = config
      end
    end

    def add_in_place_option(opts)
      message = "whether to overwrite the file or not"
      opts.on("-i", "--in-place", message) do |bool|
        self.options[:in_place] = bool
      end
    end

    def add_generate_config_option(opts)
      message = "generate a .scss-beautifier config with defaults"
      opts.on("-g", "--gen-config", message) do |bool|
        self.options[:generate_config] = bool
      end
    end

    def unindent(str)
      str.gsub(/^#{str.scan(/^[ ]+(?=\S)/).min}/, "")
    end

  end
end