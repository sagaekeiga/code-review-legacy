# == Schema Information
#
# Table name: tags
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ApplicationRecord

  class << self
    #
    # ケースインセンシティブの where
    #
    # @param [Array] args Ex. { name: ['ruby', 'java'] }
    #
    # @return [Array<Tag>]
    #
    def c_ins_where(*args)
      args = args.first
      args.values.flatten.map do |value|
        Tag.where("#{args.keys.first} ILIKE ?",  value)
      end.flatten
    end

    #
    # 頭文字に一致するタグを取得する
    #
    # @param [String] init 頭文字
    #
    # @return [Tag::ActiveRecord_Relation]
    #
    def match_by(initial)
      Tag.where("name ILIKE ?", "#{initial}%")
    end
  end
end
