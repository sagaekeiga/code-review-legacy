module RailsBestPractices
  module Core
    class ChecksLoader
      def initialize(config)
        @config = config
      end

      # read the checks from yaml config.
      def checks_from_config
        @checks ||= YAML.load @config.get_input_stream.read.to_s
      end

    end
  end
end
