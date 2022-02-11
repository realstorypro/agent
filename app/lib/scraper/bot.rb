# frozen_string_literal: true

module Scraper
  # Responsible for all the scraping logic
  class Bot
    BASE_URL = 'https://www.crunchbase.com'
    HEADLESS_PROXY = 'localhost:8080'

    def initialize
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--disable-blink-features=AutomationControlled')

      options.add_argument("--proxy-server=http://#{HEADLESS_PROXY}")
      options.add_argument('--ignore-ssl-errors=yes')
      options.add_argument('--ignore-certificate-errors')

      @driver = Selenium::WebDriver::Driver.for :chrome, capabilities: options
    end

    def scrape(companies:)
      # 1. Lets go through companies
      companies.shuffle.each_with_index do |company, index|
        # 1. lets scrape the company
        scrape_company(company: company)

        # 2. Always start off with a random sleep
        sleep(rand(10..20))

        # 3. Lets take a long break every 10 records to simulate a tired human
        sleep(rand(100..200)) if (index % 10).zero? && index != 0

      end
    end

    def scrape_company(company:)
      Rails.logger.debug "Scraping #{company.name}"

      # 1. Lets go to google, and search for the crunchbase query
      @driver.get("https://www.google.com/search?q=#{ERB::Util.url_encode(company.name)} crunchbase")

      # 2. Lets click that link
      @driver.find_elements(:xpath, "(//div[@class='yuRUbf'])[1]//a")[0].click

      # 3. lets make sure that we pulled up the actual company
      begin
        @driver.find_element(:css, '.profile-name')
      rescue Selenium::WebDriver::Error::NoSuchElementError
        Rails.logger.debug 'profile  not found'
        company.error = true
        company.save

        return
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        # sometimes this bugs out, lets just return and do it again at some point
        return
      end

      # 4. Does the people tab exist?
      begin
        @driver.find_element(:xpath, "//span[normalize-space()='People']")
        Rails.logger.debug "people's tab found"
      rescue Selenium::WebDriver::Error::NoSuchElementError
        Rails.logger.debug "The people's tab does not exist"

        company.error = true
        company.save

        return
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        # sometimes this bugs out, lets just return and do it again at some point
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
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        # sometimes this bugs out, lets just return and do it again at some point
        return
      end

      # 6. Lets grab a location (sometimes its unavailable)
      begin
        company.location = @driver.find_element(:xpath,
                                                '/html/body/chrome/div/mat-sidenav-container/mat-sidenav-content/div/ng-component/entity-v2/page-layout/div/div/div/page-centered-layout[2]/div/row-card/div/div[1]/profile-section/section-card/mat-card/div[2]/div/fields-card/ul/li[1]/label-with-icon/span/field-formatter/identifier-multi-formatter/span').text
      rescue Selenium::WebDriver::Error::NoSuchElementError
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        # sometimes this bugs out, lets just return and do it again at some point
        return
      end

      Rails.logger.debug "located in: #{company.location} with a url: #{company.url}"

      company.save

      sleep(rand(10..25))

      # 7. lets scrape the contacts
      scrape_contacts(company: company, url: "#{@driver.current_url}/people")
    end

    def scrape_contacts(company:, url:)
      # 1. Lets pull up the URL
      @driver.get(url)

      # 1.1 lets wait 5 seconds to ensure the page loads
      sleep(5)

      # 2. Lets find people
      begin
        names = @driver.find_elements(:xpath, "//contact-details//div[@class='name']//field-formatter")
        titles = @driver.find_elements(:xpath, "//contact-details//div[@class='jobInfo']//div[1]")
      rescue Selenium::WebDriver::Error::NoSuchElementError
        Rails.logger.debug 'no people found'
        return
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        # sometimes this bugs out, lets just return and do it again at some point
        return
      end

      # 3. Erase all company contacts prior to adding them
      company.contacts.delete_all

      # 4. Loop over the people and add them
      names.each_with_index do |full_name, index|
        # ignore if there's no title
        next if titles[index].nil?

        title = titles[index].text

        # ignoring board members and advisors
        next if ['Board Member', 'Advisor'].include?(title)

        first_name = full_name.text.split(' ')[0]
        last_name = full_name.text.split(' ')[1]

        Rails.logger.debug "Found: #{title} #{first_name} #{last_name}"
        company.contacts.create(first_name: first_name, last_name: last_name, title: title)
      end

      company.found = true
      company.save

      Rails.logger.debug "finished scraping #{company.name}"

      # 5. Lets pause for a little bit to prevent automation detection
      sleep(rand(15..30))
    end

    def msg_slack(msg)
      HTTParty.post(ENV['SLACK_URL'].to_s, body: { text: msg }.to_json)
    end
  end
end
