class UserDevice < ApplicationRecord
  belongs_to :push_notification_device
  belongs_to :user
end
