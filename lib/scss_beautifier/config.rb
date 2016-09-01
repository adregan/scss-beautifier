require "yaml"

module SCSSBeautifier
  class Config

    def initialize(config_location)
      @config = parse_config(config_location)
    end

    def parse_config(config_location)
      YAML.load(File.read(config_location))
    end

    def formatters
      enabled_formatters = []
      @config["formatters"].each do |formatter, options|
        if options["enabled"]
          klass = SCSSBeautifier::Formatters.const_get(formatter.split("_").map(&:capitalize).join)
          enabled_formatters << klass.new(options)
        end
      end
      enabled_formatters
    end

    def tab_style
      @config["tab_style"] || "  "
    end

  end
end
