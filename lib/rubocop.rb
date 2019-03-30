require "pronto/runner"
require 'pronto/file_change'
require 'rubocop'
require 'rubocop/file_change_cop'
class Rubocop < Pronto::Runner
  def self.run(file_change)
    file_change = Pronto::FileChange.new(file_change)
    ::Rubocop::FileChangeCop.new(file_change).messages
  end
end
