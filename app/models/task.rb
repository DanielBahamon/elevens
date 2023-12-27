class Task < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :club
  belongs_to :duel

  validates :description, presence: true
  validate :unique_task_for_user, on: :create

  private

  def unique_task_for_user
    existing_task = Task.find_by(user_id: user_id, description: description)
    errors.add(:base, 'This task already exists for the user') if existing_task.present?
  end
end
