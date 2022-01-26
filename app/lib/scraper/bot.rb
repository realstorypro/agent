# frozen_string_literal: true

module Scraper
  class Bot
    BASE_URL = 'https://www.crunchbase.com'

    def initialize
      @driver = Selenium::WebDriver::Driver.for :chrome
    end

    def base?
      BASE_URL
    end
  end
end
