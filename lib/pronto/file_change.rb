module Pronto
  class FileChange
    def initialize(data = {})
      @content = data[:content]
      @path = data[:filename]
    end

    def content
      @content
    end

    def path
      @filename
    end
  end
end