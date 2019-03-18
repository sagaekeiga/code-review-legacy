module RailsBestPractices
  class Analyzer
    # initialize
    #
    # @param [String] path where to generate the configuration yaml file
    # @param [Hash] options
    def initialize(path, options = {}, pull:)
      @path = File.expand_path(path || '.')
      @options = options
      @options['exclude'] ||= []
      @options['only'] ||= []
      @options['debug'] ||= true
      # @MEMO 差分ファイルに対してのみ解析をかける
      @pull = pull
      @zip = Github::Request.repo_archive(repo: @pull.repo, pull: @pull)
      zipfile = Tempfile.new('file')
      zipfile.binmode
      zipfile.write(@zip.body)
      zipfile.close
      @zipfile = zipfile
      Zip::File.open(zipfile.path) do |zip|
        @entries = zip.map.with_index do |entry, index|
          @path = entry.name if index == 0
          @options['config'] = entry if entry.name.include?('rails_best_practices.yml')
          entry if entry.ftype == :file && %w[.rb .erb .rake .rhtml .haml .slim .builder .rxml .rabl].include?(File.extname(entry.name))
        end.reject(&:blank?)
      end
    end

    # Analyze rails codes.
    #
    # there are two steps to check rails codes,
    #
    # 1. prepare process, check all model and mailer files.
    # 2. review process, check all files.
    #
    # if there are violations to rails best practices, output them.
    #
    # @param [String] path the directory of rails project
    # @param [Hash] options
    def analyze 
      Core::Runner.base_path = @path
      Core::Runner.config = @options['config']
      @runner = Core::Runner.new
      analyze_source_codes
      analyze_vcs
    end

    def app_name
      @path
    end

    def process(process)
      parse_files.each do |file|
        begin
          puts file if @options['debug']
          target_file = @entries.detect { |entry| entry.name == file }
          target_file_content = target_file.get_input_stream.read.to_s.force_encoding('UTF-8')

          @runner.send(process, file, target_file_content)
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
        files = @entries.map { |entry| entry.name }
        files = file_sort(files)

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

    # Output the analyze result.
    def output
      output_json_errors
    end

    # output errors with json format.
    def output_json_errors
      errors.map do |err|
        {
          filename:    err.filename,
          line_number: err.line_number,
          message:     err.message
        }
      end
    end

    #
    # zipファイルを解凍したフォルダを返す
    #
    def expand_dirs_to_files(zipfile)
      Zip::File.open(zipfile.path) do |zip|
        zip.each do |entry|
          entry.name if entry.ftype == :file
        end
      end
    end

  end
end
