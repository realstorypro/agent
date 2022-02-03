# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string
#  fields     :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  found      :boolean          default("false")
#  error      :boolean          default("false")
#  exported   :boolean          default("false")
#

# frozen_string_literal: true

# Manages the airtable companies internally
class Company < ApplicationRecord
  jsonb_accessor  :fields,
                  slug: :string,
                  url: :string,
                  location: :string

  validates :name, uniqueness: true
  has_many :contacts, dependent: :destroy

  def domain_with_www
    return "www.#{url}" if url.present?

    ''
  end
end
