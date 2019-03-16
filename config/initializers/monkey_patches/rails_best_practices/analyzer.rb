module RailsBestPractices
  class Analyzer
    # initialize
    #
    # @param [String] path where to generate the configuration yaml file
    # @param [Hash] options
    def initialize(path, options = {}, pull:)
      @path = File.expand_path(path || '.')
      # @MEMO 差分ファイルに対してのみ解析をかける
      @pull = Pull.last
      @change_files = @pull.changed_files

      @options = options
      @options['exclude'] ||= []
      @options['only'] ||= []
    end

    def process(process)
      parse_files.each do |file|
        begin
          puts file if @options['debug']
          target_file = @change_files.detect { |changed_file| changed_file.filename == file } 
          target_file_content = Base64.decode64(target_file.content).force_encoding('UTF-8')

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
        files = @change_files.map{ |content| content.filename }
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
      output_json_errors.each do |err|

      end
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
  end
end
