class Check
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :path,                :string
  attribute :annotation_level,    :string, default: 'warning'
  attribute :start_line,          :string
  attribute :end_line,            :string
  attribute :message,             :string
  attribute :title,               :string

  class << self
    def initialize(data = {})
      self.path = data[:path]
      self.start_line = data[:start_line]
      self.end_line = data[:end_line]
      self.message = data[:message]
      self.title = data[:title]
    end
  end
end