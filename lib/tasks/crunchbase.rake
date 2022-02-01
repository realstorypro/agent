# frozen_string_literal: true

namespace :crunchbase do
  desc 'TODO'
  task scrape: :environment do

    bot = Scraper::Bot.new
    companies = Company.where(found: false, error: false, exported: false)
    bot.scrape(companies: companies)

    # companies.shuffle.each do |company|
    #   bot.scrape(company)
    # end
  end

  desc 'TODO'
  task prospect: :environment do
  end
end
