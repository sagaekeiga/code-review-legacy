class Rubocop < Pronto::Runner
  class FileChangeCop
    def initialize(file_change, pull)
      @file_change = file_change
      @pull = pull
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
        # Rails.logger.info "store: #{store}"
        store.options_config = ENV['RUBOCOP_CONFIG'] if ENV['RUBOCOP_CONFIG']
        # Rails.logger.info "ENV['RUBOCOP_CONFIG']: #{ENV['RUBOCOP_CONFIG']}"
        # Rails.logger.info "store.for(path): #{store.for(path)}"
        # Rails.logger.ap "path: #{path}"
        # sss = store.for(path)
        # ddd ||= begin
        #   hash_rubocop_yml = YAML.load Github::Request.rubocop_yml(pull: @pull)
        #   puts hash_rubocop_yml
        #   RuboCop::Config.new(hash_rubocop_yml, '.rubocop.yml')
        # end
        # Rails.logger.info sss.class == ddd.class
        hash_rubocop_yml = YAML.load Github::Request.rubocop_yml(pull: @pull)
        config = RuboCop::Config.new(hash_rubocop_yml, '.rubocop.yml')
        config = RuboCop::ConfigLoader.merge_with_default(config, '.rubocop.yml')
        Rails.logger.ap config
        config
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
        ::RuboCop::ProcessedSource.new(content, config.target_ruby_version, path)
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