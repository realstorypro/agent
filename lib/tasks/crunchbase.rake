# frozen_string_literal: true

namespace :crunchbase do
  desc 'TODO'
  task scrape: :environment do
    # company_name = 'ManagedMethods'

    args = ['--disable-blink-features=AutomationControlled']
    options = Selenium::WebDriver::Chrome::Options.new(args: args)
    driver = Selenium::WebDriver::Driver.for :chrome, options: options

    bot = Scraper::Bot.new(driver: driver)

    companies = Airtable::Company.all(filter: '{Scraped} = FALSE()')

    companies.shuffle.each do |company_name|
      bot.scrape(company_name: company_name.fields["Name"])
    end
  end

  desc 'TODO'
  task prospect: :environment do
  end
end
