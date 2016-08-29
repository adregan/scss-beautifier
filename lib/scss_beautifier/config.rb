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
      enabled_formatters = @config["formatters"].select {|_, formatter| formatter["enabled"] }.keys
      enabled_formatters.map do |formatter|
        SCSSBeautifier::Formatters.const_get(formatter.split("_").map(&:capitalize).join)
      end
    end
  end
end