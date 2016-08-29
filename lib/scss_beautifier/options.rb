require "optparse"

module Lintrunner
  class Options

    attr_reader :options

    def initialize
      @options = {}
      @option_parser = OptionParser.new do |opts|
        add_banner(opts)
        add_config_option(opts)
        add_context_option(opts)
        add_include_path_option(opts)
        add_reporter_option(opts)
        add_ignore_option(opts)
        add_colorize_option(opts)
      end
    end

    def parse(args)
      @option_parser.parse!(args)
      add_defaults
      options[:path] = args.first if args.first
      options
    end

    private

    def add_defaults
      options[:config] ||= ".lintrunner_config"
      options[:context] ||= Dir.pwd
      options[:include_paths] = Array(options[:include_paths]) << options[:context]
      options[:include_paths].uniq!
      options[:reporter] ||= "text"
      options[:path] = Dir.pwd
      options[:ignore] ||= []
    end

    def add_banner(opts)
      opts.banner = unindent(<<-BANNER)
        Run multiple linters with various runners
        Usage: #{opts.program_name} [options] [path]
      BANNER
    end

    def add_config_option(opts)
      message = "the configuration file for lintrunner (default: .lintrunner_config)"
      opts.on("-c", "--config config", message, String) do |config|
        self.options[:config] = config
      end
    end

    def add_context_option(opts)
      message = "the path on which lintrunner will execute in (default: current path)"
      opts.on("-x", "--context path", message, String) do |path|
        self.options[:context] = Pathname.new(path).realpath.to_s
      end
    end

    def add_include_path_option(opts)
      message = "the paths to add to load paths (the context is in the load path)"
      opts.on("--include_path path1,...", message, Array) do |paths|
        self.options[:include_paths] = paths
      end
    end

    def add_reporter_option(opts)
      message = "the reporter that lintrunner uses to report results"
      opts.on("--reporter reporter", message, String) do |reporter|
        self.options[:reporter] = reporter
      end
    end

    def add_ignore_option(opts)
      message = "the messages to ignore for this lintrunner execution"
      opts.on("--ignore messages", message, Array) do |messages|
        self.options[:ignore] = messages
      end
    end

    def add_colorize_option(opts)
      message = "force colorized setting for output"
      opts.on("--colorize", "--[no-]colorize", message) do |bool|
        Rainbow.enabled = bool
      end
    end

    def unindent(str)
      str.gsub(/^#{str.scan(/^[ ]+(?=\S)/).min}/, "")
    end

  end
end