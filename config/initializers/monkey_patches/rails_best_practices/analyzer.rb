module RailsBestPractices

  # RailsBestPractices Analyzer helps you to analyze your rails code, according to best practices on https://rails-bestpractices.
  # if it finds any violatioins to best practices, it will give you some readable suggestions.
  #
  # The analysis process is partitioned into two parts,
  #
  # 1. prepare process, it checks only model and mailer files, do some preparations, such as remember model names and associations.
  # 2. review process, it checks all files, according to configuration, it really check if codes violate the best practices, if so, remember the violations.
  #
  # After analyzing, output the violations.
  class Analyzer
    # initialize
    #
    # @param [String] path where to generate the configuration yaml file
    # @param [Hash] options
    def initialize(path, options = {})
      @path = File.expand_path(path || '.')
      # puts @path
      # plain_output(@path, 'red')
      # @contents = Github::Request.files(pull: Pull.first)
      @change_files = Pull.first.changed_files

      @options = options
      @options['exclude'] ||= []
      @options['only'] ||= []
    end

    def process(process)
      parse_files.each do |file|
        begin
          puts "file #{file}"
          puts file.class

          puts file if @options['debug']
          # ana_file = File.read(file)
          puts 1111
          target_file = @change_files.detect { |changed_file| changed_file.path == file }
          puts 2222
          ana_file = target_file.content

          @runner.send(process, file, ana_file)
        rescue StandardError
          if @options['debug']
            warning = "#{file} looks like it's not a valid Ruby file.  Skipping..."
            plain_output(warning, 'red')
          end
        end
        @bar.increment if display_bar?
      end
      @runner.send("after_#{process}")
    end
    # get all files for parsing.
    #
    # @return [Array] all files for parsing
    def parse_files
      @parse_files ||= begin
        files = @change_files.map{ |content| content.filename }
        # files = expand_dirs_to_files(@path)
        files = file_sort(files)
        puts files

        if @options['only'].present?
          files = file_accept(files, @options['only'])
        end

        # By default, tmp, vender, spec, test, features are ignored.
        %w[vendor spec test features tmp].each do |dir|
          files = file_ignore(files, File.join(@path, dir)) unless @options[dir]
        end

        # Exclude files based on exclude regexes if the option is set.
        @options['exclude'].each do |pattern|
          files = file_ignore(files, pattern)
        end

        %w[Capfile Gemfile Gemfile.lock].each do |file|
          files.unshift File.join(@path, file)
        end

        files.compact
      end
    end

  end
end