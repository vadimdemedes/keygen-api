# frozen_string_literal: true

module Licenses
  class ProductPolicy < ApplicationPolicy
    authorize :license

    def show?
      verify_permissions!('product.read')

      case bearer
      in role: { name: 'admin' | 'developer' | 'sales_agent' | 'support_agent' | 'read_only' }
        allow!
      in role: { name: 'product' } if license.product == bearer
        allow!
      in role: { name: 'user' } if license.user == bearer
        ENV.key?('KEYGEN_ENABLE_PERMISSIONS')
      in role: { name: 'license' } if license == bearer
        ENV.key?('KEYGEN_ENABLE_PERMISSIONS')
      else
        deny!
      end
    end
  end
end