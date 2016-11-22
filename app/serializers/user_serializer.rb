class UserSerializer < BaseSerializer
  type :users

  attributes [
    :id,
    :name,
    :email,
    :metadata,
    :created,
    :updated
  ]

  belongs_to :account
  has_many :licenses
  has_many :products, through: :licenses
  has_many :machines, through: :licenses
  has_many :tokens
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string
#  email                  :string
#  password_digest        :string
#  account_id             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_reset_token   :string
#  password_reset_sent_at :datetime
#  deleted_at             :datetime
#  metadata               :json
#
# Indexes
#
#  index_users_on_account_id            (account_id)
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email)
#  index_users_on_password_reset_token  (password_reset_token)
#
