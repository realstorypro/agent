# frozen_string_literal: true

namespace :airtable do
  desc 'TODO'
  task download: :environment do
    remaining_companies = Company.where(found: false, error: false)

    unless remaining_companies.count < 100
      puts 'We still have over 100 companies to scrape. No download necessary.'

      exit
    end

    unscraped_records = Airtable::Company.unscraped
    plucked_records = unscraped_records.sample(200)

    plucked_records.each do |record|
      Company.find_or_create_by(name: record.fields['Name'])
    end

    puts unscraped_records.count, unscraped_records.class
  end

  desc 'TODO'
  task upload: :environment do
  end
end
