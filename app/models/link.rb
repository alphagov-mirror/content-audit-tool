class Link < ApplicationRecord
  PARENT = "parent".freeze
  POLICY_AREAS = "policy_areas".freeze
  POLICIES = "policies".freeze
  PRIMARY_ORG = "primary_publishing_organisation".freeze
  ALL_ORGS = "organisations".freeze
  TOPICS = "topics".freeze
  TAXONOMIES = "taxons".freeze

  after_save { ReportRow.precompute(source) }

  belongs_to :source,
             class_name: "Item",
             foreign_key: :source_content_id,
             primary_key: :content_id,
             optional: true

  belongs_to :target,
             class_name: "Item",
             foreign_key: :target_content_id,
             primary_key: :content_id,
             optional: true
end
