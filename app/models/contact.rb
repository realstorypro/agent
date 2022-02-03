# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id            :integer          not null, primary key
#  first_name    :string
#  last_name     :string
#  fields        :jsonb
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  uploaded      :boolean          default("false")
#  enriched      :boolean          default("false")
#  invalid_email :boolean          default("false")
#  email         :string
#  no_address    :boolean
#

class Contact < ApplicationRecord
  belongs_to :company
  jsonb_accessor  :fields,
                  title: :string,
                  lat: :string,
                  lng: :string,
                  timezone: :string,
                  twitter: :string,
                  linkedin_url: :string
end
