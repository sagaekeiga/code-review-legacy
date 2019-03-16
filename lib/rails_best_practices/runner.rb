module RailsBestPractices
  class Runner
    def self.run
      $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
      require 'rails_best_practices'
      require 'rails_best_practices/command'
    end
  end
end