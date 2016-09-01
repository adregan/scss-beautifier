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

    def tab_style
      @config["tab_style"] || "  "
    end

    def options_for(formatter)
      klass_name = formatter.to_s.split("::").last
      @config["formatters"][underscore(klass_name)]
    end

    def underscore(string)
       string.gsub(/::/, '/').
       gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
       gsub(/([a-z\d])([A-Z])/,'\1_\2').
       tr("-", "_").
       downcase
     end
  end
end
