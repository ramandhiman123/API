# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user, inverse_of: :tasks
  has_many :task_assignments, dependent: :destroy, inverse_of: :task
  has_many :assignees, through: :task_assignments, source: :user
  has_many :comments, dependent: :destroy, inverse_of: :task
  validates :title, presence: true
  scope :ordered, -> { order(priority: :asc, created_at: :asc) }
  scope :owned_by, ->(user) { left_joins(:task_assignments).where(user: user) }
  scope :assigned_to, ->(user) { left_joins(:task_assignments).where(task_assignments: { user_id: user.id }) }
  scope :accessible_by, lambda { |user|
    return none unless user
    owned_by(user).or(assigned_to(user)).distinct
  }
end