# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/object/blank'
begin
  require 'active_support/core_ext/object/try'
rescue LoadError
  require 'active_support/core_ext/try'
end
require 'active_support/inflector'

module RailsBestPractices
  module Core
    # Runner is the main class, it can check source code of a filename with all checks (according to the configuration).
    #
    # the check process is partitioned into two parts,
    #
    # 1. prepare process, it will do some preparations for further checking, such as remember the model associations.
    # 2. review process, it does real check, if the source code violates some best practices, the violations will be notified.
    class Runner
      attr_reader :checks

      # set the base path.
      #
      # @param [String] path the base path
      def self.base_path=(path)
        @base_path = path
      end

      # get the base path, by default, the base path is current path.
      #
      # @return [String] the base path
      def self.base_path
        @base_path || '.'
      end

      # set the configuration path
      #
      # @param path [String] path to rbc config file
      def self.config=(config)
        @config = config
      end

      # get the configuration path, if will default to config/rails_best_practices.yml
      #
      # @return [String] the config path
      def self.config
        custom_config = @config || File.join(Runner.base_path, 'config/rails_best_practices.yml')
        custom_config ? custom_config : RailsBestPractices::Analyzer::DEFAULT_CONFIG
      end

      # initialize the runner.
      #
      # @param [Hash] options pass the prepares and reviews.
      def initialize(options = {})
        @config = self.class.config

        lexicals = Array(options[:lexicals])
        prepares = Array(options[:prepares])
        reviews = Array(options[:reviews])

        checks_loader = ChecksLoader.new(@config)
        @lexicals = lexicals.empty? ? checks_loader.load_lexicals : lexicals
        @prepares = prepares.empty? ? load_prepares : prepares
        @reviews = reviews.empty? ? checks_loader.load_reviews : reviews
        load_plugin_reviews if reviews.empty?

        @lexical_checker ||= CodeAnalyzer::CheckingVisitor::Plain.new(checkers: @lexicals)
        @plain_prepare_checker ||= CodeAnalyzer::CheckingVisitor::Plain.new(checkers: @prepares.select { |checker| checker.is_a? Prepares::GemfilePrepare })
        @default_prepare_checker ||= CodeAnalyzer::CheckingVisitor::Default.new(checkers: @prepares.reject { |checker| checker.is_a? Prepares::GemfilePrepare })
        @review_checker ||= CodeAnalyzer::CheckingVisitor::Default.new(checkers: @reviews)
      end

    end
  end
end
