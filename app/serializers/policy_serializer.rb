# frozen_string_literal: true

class PolicySerializer < BaseSerializer
  type :policies

  attribute :name
  attribute :duration
  attribute :strict
  attribute :floating
  attribute :use_pool
  attribute :max_machines
  attribute :max_cores
  attribute :max_uses
  attribute :concurrent
  attribute :fingerprint_uniqueness_strategy
  attribute :fingerprint_matching_strategy
  attribute :scheme
  attribute :encrypted
  attribute :protected
  attribute :require_product_scope
  attribute :require_policy_scope
  attribute :require_machine_scope
  attribute :require_fingerprint_scope
  attribute :require_check_in
  attribute :check_in_interval
  attribute :check_in_interval_count
  attribute :heartbeat_duration
  attribute :metadata do
    @object.metadata&.transform_keys { |k| k.to_s.camelize :lower } or {}
  end
  attribute :created do
    @object.created_at
  end
  attribute :updated do
    @object.updated_at
  end

  relationship :account do
    linkage always: true do
      { type: :accounts, id: @object.account_id }
    end
    link :related do
      @url_helpers.v1_account_path @object.account_id
    end
  end
  relationship :product do
    linkage always: true do
      { type: :products, id: @object.product_id }
    end
    link :related do
      @url_helpers.v1_account_policy_product_path @object.account_id, @object
    end
  end
  relationship :pool do
    link :related do
      @url_helpers.v1_account_policy_keys_path @object.account_id, @object
    end
  end
  relationship :licenses do
    link :related do
      @url_helpers.v1_account_policy_licenses_path @object.account_id, @object
    end
  end

  relationship :entitlements do
    link :related do
      @url_helpers.v1_account_policy_entitlements_path @object.account_id, @object
    end
  end

  link :self do
    @url_helpers.v1_account_policy_path @object.account_id, @object
  end
end