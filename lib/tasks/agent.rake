namespace :agent do
  desc 'assigns companies for agent to scrape'
  task take: :environment do
    max_assigned = 550
    assigned_companies = Company.where(found: false, error: false, agent: ENV['AGENT_CODENAME'])

    companies_to_assign = max_assigned - assigned_companies.count

    abort("You have maximum number of #{max_assigned} companies assigned.") if companies_to_assign.zero?

    puts "Assigning #{companies_to_assign} companies to #{ENV['AGENT_CODENAME']} 🥷"

    unassigned_companies = Company.where(found: false, error: false, agent: nil).limit(companies_to_assign)

    unassigned_companies.each do |company|
      company.update(agent: ENV['AGENT_CODENAME'])
    end

    puts 'Done 👍'
  end

end
