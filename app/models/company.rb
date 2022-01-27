# frozen_string_literal: true

class Company < ApplicationRecord
  jsonb_accessor  :fields,
                  slug: :string,
                  url: :string,
                  location: :string,
                  keyword: :string,
                  headquarters: :string,
                  employees: :string,
                  revenue: :string,
                  status: :string,
                  ipo: :string,
                  website_tech: :string,
                  company_tech: :string

  # we don't want to have duplicate names
  validates_uniqueness_of :name
  has_many :contacts

  def domain_with_www
    return "www.#{self.url}" unless self.url.blank?

    ''
  end
end
