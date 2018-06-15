class RoleNotificationType < ApplicationRecord
  belongs_to :role
  belongs_to :wupee_notification_type
end
