# frozen_string_literal: true

module Api::V1::Licenses::Relationships
  class EntitlementsController < Api::V1::BaseController
    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!
    before_action :set_license

    def index
      authorize @license, :list_entitlements?

      @entitlements = apply_scopes(@license.entitlements)

      render jsonapi: @entitlements
    end

    def show
      authorize @license, :show_entitlement?

      @entitlement = @license.entitlements.find(params[:id])

      render jsonapi: @entitlement
    end

    def attach
      authorize @license, :attach_entitlement?

      @license_entitlements = @license.license_entitlements

      entitlements = entitlement_params.fetch(:data).map do |entitlement|
        entitlement.merge(account_id: current_account.id)
      end

      @license_entitlements.transaction do
        attached = @license_entitlements.create!(entitlements)

        CreateWebhookEventService.new(
          event: 'license.entitlements.attached',
          account: current_account,
          resource: attached
        ).execute

        render jsonapi: attached
      end
    end

    def detach
      authorize @license, :detach_entitlement?

      @license_entitlements = @license.license_entitlements
      @policy_entitlements = @license.policy_entitlements

      @license_entitlements.transaction do
        entitlement_ids = entitlement_params.fetch(:data).collect { |e| e[:entitlement_id] }

        # Block policy entitlements from being detached (must be detached from the policy)
        if @policy_entitlements.exists?(entitlement_id: entitlement_ids)
          fobidden_entitlements = @policy_entitlements.where(entitlement_id: entitlement_ids)
          forbidden_entitlement_ids = entitlement_ids & fobidden_entitlements.collect(&:entitlement_id)
          forbidden_entitlement_id = forbidden_entitlement_ids.first
          forbidden_idx = entitlement_ids.find_index(forbidden_entitlement_id)

          return render_forbidden(
            detail: "cannot detach entitlement '#{forbidden_entitlement_id}' granted by policy",
            source: {
              pointer: "/data/#{forbidden_idx}/id"
            }
          )
        end

        entitlements = @license_entitlements.where(entitlement_id: entitlement_ids)
        detached = @license_entitlements.delete(entitlements)

        CreateWebhookEventService.new(
          event: 'license.entitlements.detached',
          account: current_account,
          resource: detached
        ).execute
      end
    end

    private

    def set_license
      @license = FindByAliasService.new(current_account.licenses, params[:license_id], aliases: :key).call

      Keygen::Store::Request.store[:current_resource] = @license
    end

    typed_parameters do
      options strict: true

      on :attach do
        param :data, type: :array do
          items type: :hash do
            param :type, type: :string, inclusion: %w[entitlement entitlements], transform: -> (k, v) { [] }
            param :id, type: :string, transform: -> (k, v) {
              [:entitlement_id, v]
            }
          end
        end
      end

      on :detach do
        param :data, type: :array do
          items type: :hash do
            param :type, type: :string, inclusion: %w[entitlement entitlements], transform: -> (k, v) { [] }
            param :id, type: :string, transform: -> (k, v) {
              [:entitlement_id, v]
            }
          end
        end
      end
    end
  end
end