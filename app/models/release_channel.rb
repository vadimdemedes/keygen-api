# frozen_string_literal: true

class ReleaseChannel < ApplicationRecord
  include Limitable
  include Pageable

  belongs_to :account

  validates :account,
    presence: { message: 'must exist' }

  validates :key,
    presence: true,
    uniqueness: { message: 'already exists', scope: :account_id },
    inclusion: { in: %w[stable rc beta alpha dev] }
end