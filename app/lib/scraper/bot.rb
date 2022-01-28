# frozen_string_literal: true

module Scraper
  # Responsible for all the scraping logic
  class Bot
    BASE_URL = 'https://www.crunchbase.com'

    def initialize(driver:)
      @driver = driver
    end

    def scrape(company_name:)
      Rails.logger.debug "Scraping #{company_name}"

      # 1. Lets go to google, and search for the crunchbase query
      @driver.get("https://www.google.com/search?q=#{company_name} crunchbase")

      # 2. Lets click that link
      @driver.find_elements(:xpath, "(//div[@class='yuRUbf'])[1]//a")[0].click

      sleep(rand(45..150))

      # @driver.quit
    end
  end
end
