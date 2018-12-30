class Content
  include ActiveModel::Model
  include Draper::Decoratable
  attr_accessor :name, :path, :content, :type
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  TYPE = {
    file: 1000,
    dir:  2000
  }.with_indifferent_access

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  class << self
    def types
      TYPE
    end

    def initializes(contents:)
      dir_and_file_contents = []
      file_contents = []
      dir_contents = []
      contents.each do |content|
        sort_before_content = new(
          name: content[:name],
          path: content[:path],
          content: content[:content],
          type: content[:type].eql?('dir') ? :dir : :file
        )
        if sort_before_content.dir?
          dir_contents << sort_before_content
        else
          file_contents << sort_before_content
        end
      end
      dir_and_file_contents << dir_contents
      dir_and_file_contents << file_contents
      dir_and_file_contents.flatten!.reject(&:blank?)
    end
  end

  TYPE.each do |key, value|
    define_method("#{key}?") { @type == value }
    define_method("#{key}!") { @type = value }
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def type=(value = nil)
    if TYPE.has_key?(value) || value.blank?
      @type = TYPE[value]
    elsif TYPE.has_value?(value)
      @type = value
    else
      raise ArgumentError "'#{value}' is not a valid type"
    end
  end

  def type
    TYPE.key(@type)
  end
end