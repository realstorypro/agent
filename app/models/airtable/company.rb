# frozen_string_literal: true

module Airtable
  class Company < Airrecord::Table
    self.base_key = 'appJsinKEWPlytT8z'
    self.table_name = 'Companies'

    # def self.unscarped_owned
    #   all(filter: "AND( {Scraped} = FALSE(), {Agent} = '#{ENV['AGENT_CODENAME']}' )")
    # end

    def self.unscraped
      all(filter: 'AND( {Scraped} = FALSE(), {Agent} = BLANK() )')
    end
  end
end
