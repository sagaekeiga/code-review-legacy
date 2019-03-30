class Rubocop < Pronto::Runner
  class FileChangeCop
    def initialize(file_change)
      @file_change = file_change
    end

    def messages
      return [] unless valid?
      offences
    end

    private

    attr_reader :file_change, :runner

    def valid?
      return false if config.file_to_exclude?(path)
      return true if config.file_to_include?(path)
      true
    end

    def path
      @path ||= file_change.path.to_s
    end

    def content
      @content ||= file_change.content.to_s
    end

    def config
      @config ||= begin
        store = ::RuboCop::ConfigStore.new
        store.options_config = ENV['RUBOCOP_CONFIG'] if ENV['RUBOCOP_CONFIG']
        store.for(path)
      end
    end

    def offences
      team
        .inspect_file(processed_source)
        .sort
        .reject(&:disabled?)
    end

    def team
      @team ||= ::RuboCop::Cop::Team.new(registry, config)
    end

    def registry
      @registry ||= ::RuboCop::Cop::Registry.new(RuboCop::Cop::Cop.all)
    end

    def processed_source
      @processed_source ||=
        ::RuboCop::ProcessedSource.new(content, '2.6'.to_f, path)
    end

    def level(severity)
      case severity
      when :refactor, :convention
        :warning
      when :warning, :error, :fatal
        severity
      end
    end
  end
end