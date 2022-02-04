# frozen_string_literal: true

module Airtable
  class Company < Airrecord::Table
    self.base_key = 'appJsinKEWPlytT8z'
    self.table_name = 'Companies'

    def self.unscraped
      all(filter: '{Scraped} = FALSE()')
    end

    def self.scraped
      all(filter: '{Scraped} = TRUE()')
    end
  end
end
