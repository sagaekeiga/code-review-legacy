# == Schema Information
#
# Table name: notifications
#
#  id            :bigint(8)        not null, primary key
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pull_id       :bigint(8)
#  resource_id   :integer
#  reviewer_id   :bigint(8)
#
# Indexes
#
#  index_notifications_on_pull_id      (pull_id)
#  index_notifications_on_reviewer_id  (reviewer_id)
#

class Notification < ApplicationRecord
end
