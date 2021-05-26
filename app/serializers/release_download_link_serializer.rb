# frozen_string_literal: true

class ReleaseDownloadLinkSerializer < BaseSerializer
  type 'release-download-links'

  attribute :url
  attribute :ttl
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
  relationship :release do
    linkage always: true do
      { type: :releases, id: @object.release_id }
    end
    link :related do
      @url_helpers.v1_account_release_path @object.account_id, @object.release_id
    end
  end

  link :related do
    @url_helpers.v1_account_release_blob_path @object.account_id, @object.release_id
  end
end