# frozen_string_literal: true

namespace :crunchbase do
  desc 'scrapes crunchbase'
  task scrape: :environment do

    bot = Scraper::Bot.new
    companies = Company.where(found: false, error: false, agent: ENV['AGENT_CODENAME'])

    if companies.count.zero?
      puts 'there are no companies left to scrape'
      return
    end
    
    bot.scrape(companies: companies)
  end

  desc 'TODO'
  task prospect: :environment do
  end
end
