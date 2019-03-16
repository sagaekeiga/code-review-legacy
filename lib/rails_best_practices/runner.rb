module RailsBestPractices
  class Runner
    def self.run
      require 'rails_best_practices'
      puts require 'rails_best_practices/command'
    end
  end
end
