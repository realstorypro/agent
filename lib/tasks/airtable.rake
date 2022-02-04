# frozen_string_literal: true

namespace :airtable do
  desc 'TODO'
  task download: :environment do
    # remaining_companies = Company.where(found: false, error: false)

    unscraped_records = Airtable::Company.unscraped
    unscraped_records.each do |record|
      Company.find_or_create_by(name: record.fields['Name'])
      puts "adding unscraped #{record.fields['Name']}"
    end

    scraped_records = Airtable::Company.scraped
    scraped_records.each do |record|
      Company.find_or_create_by(name: record.fields['Name'], found: true)
      puts "adding scraped #{record.fields['Name']}"
    end

  end

  desc 'TODO'
  task upload: :environment do
  end
end
