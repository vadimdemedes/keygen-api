class Product < ApplicationRecord
  include TokenAuthenticatable
  include Resourcifiable

  belongs_to :account
  has_and_belongs_to_many :users
  has_many :policies, dependent: :destroy
  has_many :licenses, through: :policies
  has_one :token, as: :bearer, dependent: :destroy

  serialize :platforms, Array

  before_create :set_roles

  validates_associated :account, message: -> (_, obj) { obj[:value].errors.full_messages.first.downcase }
  validates :account, presence: { message: "must exist" }
  validates :name, presence: true

  scope :page, -> (page = {}) {
    paginate(page[:number]).per page[:size]
  }

  private

  def set_roles
    add_role :product
  end
end
