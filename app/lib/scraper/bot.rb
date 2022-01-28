# frozen_string_literal: true

module Scraper
  # Responsible for all the scraping logic
  class Bot
    BASE_URL = 'https://www.crunchbase.com'

    def initialize
      # args = ['--disable-blink-features=AutomationControlled']
      # options = Selenium::WebDriver::Chrome::Options.new(args: args)

      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--disable-blink-features=AutomationControlled')

      @driver = Selenium::WebDriver::Driver.for :chrome, capabilities: options
    end

    def scrape(companies:)
      # 2. Lets separate scraped companies vs scraped contacts

      # 3. Lets go through companies
      companies.shuffle.each_with_index do |company, index|

        # lets take a long break every 10 records to simulate a tired human
        sleep(rand(300..600)) if (index % 10).zero? && index != 0

        scrape_company(company: company)
      end
    end

    def scrape_company(company:)
      Rails.logger.debug "Scraping #{company.name}"

      # 1. Lets go to google, and search for the crunchbase query
      @driver.get("https://www.google.com/search?q=#{ERB::Util.url_encode(company.name)} crunchbase")

      # 2. Lets click that link
      @driver.find_elements(:xpath, "(//div[@class='yuRUbf'])[1]//a")[0].click

      # seems like the scraper gets detected if its starts acting too fast
      sleep(rand(5..10))

      # 3. lets make sure that we pulled up the actual company
      begin
        @driver.find_element(:css, '.profile-name')
      rescue Selenium::WebDriver::Error::NoSuchElementError
        Rails.logger.debug 'profile  not found'
        company.error = true
        company.save

        return
      end

      # 4. Does the company tab exist?
      begin
        @driver.find_element(:xpath, "//span[normalize-space()='People']")
        Rails.logger.debug "people's tab found"
      rescue Selenium::WebDriver::Error::NoSuchElementError
        Rails.logger.debug "The people's tab does not exist"

        company.error = true
        company.save

        return
      end

      # 5. lets get the company url, and clean it up so we only get the domain name
      begin
        company.url = @driver.find_element(:xpath, '//profile-section[1]//link-formatter/a')
                             .text.gsub('/', '').gsub('www.', '')
      rescue Selenium::WebDriver::Error::NoSuchElementError
        company.error = true
        company.save

        return
      end

      # 6. Lets grab a location (sometimes its unavailable)
      begin
        company.location = @driver.find_element(:xpath,
                                                '/html/body/chrome/div/mat-sidenav-container/mat-sidenav-content/div/ng-component/entity-v2/page-layout/div/div/div/page-centered-layout[2]/div/row-card/div/div[1]/profile-section/section-card/mat-card/div[2]/div/fields-card/ul/li[1]/label-with-icon/span/field-formatter/identifier-multi-formatter/span').text
      rescue Selenium::WebDriver::Error::NoSuchElementError
      end

      Rails.logger.debug "located in: #{company.location} with a url: #{company.url}"

      company.save

      sleep(rand(45..100))
    end

    def msg_slack(msg)
      HTTParty.post(ENV['SLACK_URL'].to_s, body: { text: msg }.to_json)
    end
  end
end
