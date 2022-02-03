namespace :contacts do
  desc 'enrich the scraped contacts'
  task :enrich, [:number] => :environment do |_t, args|
    msg_slack("Enriching #{args[:number]} contacts")

    contacts = Contact.where(enriched: false, invalid_email: false, uploaded: false).limit(args[:number])
    puts "Enriching #{contacts.count}..."

    contacts.each do |contact|
      # skip contacts without company
      next if contact.company.nil?

      # skip enrichment, but set enriched to yes and set no address field to true
      if contact.company.location.nil?
        puts "no address for #{contact.company.name}"
        contact.update(no_address: true, enriched: true)
        next
      end

      company_location = I18n.transliterate(contact.company.location)
      puts company_location

      geocoding_resp =
        HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?key=#{ENV['GOOGLE_MAPS_KEY']}&censor=false&address=#{company_location}")

      # skip enrichment if we get no results, but set enriched to yes and set no address field to true
      if geocoding_resp['status'] == 'ZERO_RESULTS'
        puts "No results for #{contact.company.name}"
        contact.update(no_address: true, enriched: true)
        next
      end

      coordinates = geocoding_resp['results'][0]['geometry']['location']
      contact.update(lat: coordinates['lat'], lng: coordinates['lng'])

      timezone_resp =
        HTTParty.get("https://maps.googleapis.com/maps/api/timezone/json?key=#{ENV['GOOGLE_MAPS_KEY']}&censor=false&timestamp=1331161200&location=#{contact.lat},#{contact.lng}")

      contact.update(timezone: timezone_resp['timeZoneId'], enriched: true)
    end
  end

  desc 'finding and verifying emails for scraped contacts'
  task :find_email, [:number] => :environment do |_t, args|
    msg_slack("Finding emails for #{args[:number]} contacts")

    contacts = Contact.where(enriched: true, invalid_email: false, uploaded: false, email: nil).limit(args[:number])

    contacts.each do |contact|
      begin
        first_name = I18n.transliterate(contact.first_name.downcase.capitalize)
        last_name = I18n.transliterate(contact.last_name.downcase.capitalize)
        domain = contact.company.url
      rescue StandardError
        contact.update(invalid_email: true)
        next
      end

      email_finder_resp =
        HTTParty.get "https://api.hunter.io/v2/email-finder?domain=#{domain}&first_name=#{first_name}&last_name=#{last_name}&api_key=#{ENV['HUNTER_API_KEY']}"

      # skip to the next contact if we can't find an email
      begin
        if email_finder_resp.parsed_response['data']['verification']['status'].nil?
          contact.update(invalid_email: true)
          next
        end
      rescue StandardError
        # if for some reason we get nothing just skip.
        next if email_finder_resp.nil?

        case email_finder_resp.parsed_response['errors'][0]['details']
        when 'Last name cannot only be made up of single letters'
          contact.update(invalid_email: true)
          next
        when 'This domain name cannot receive emails.'
          contact.update(invalid_email: true)
          next
        when 'The provided domain is not a valid domain name'
          contact.update(invalid_email: true)
          next
        when 'Last name has wrong format'
          contact.update(invalid_email: true)
          next
        when 'First name cannot only be made up of single letters'
          contact.update(invalid_email: true)
          next
        when "The person behind this email address has asked us directly or indirectly to stop the processing of this email. Therefore, you shouldn't process this email yourself in any way."
          contact.update(invalid_email: true)
          next
        when 'You are missing one of the following parameters: company, domain'
          contact.update(invalid_email: true)
          next
        end
      end

      if email_finder_resp.parsed_response['data'].nil?
          contact.update(invalid_email: true)
          next
      end

      contact.update(email: email_finder_resp.parsed_response['data']['email'],
                     twitter: email_finder_resp.parsed_response['data']['twitter'],
                     linkedin_url: email_finder_resp.parsed_response['data']['linkedin_url'])

      email_verifier_resp =
        HTTParty.get "https://api.hunter.io/v2/email-verifier?email=#{contact.email}&api_key=#{ENV['HUNTER_API_KEY']}"

      begin
        # skip to the next contact if the email is not valid
        if email_verifier_resp.parsed_response['data']['score'] < 80
          contact.update(invalid_email: true)
          next
        end
      rescue StandardError
        # skip if for some reason we are getting an error
        puts 'error w/ response'
        next
      end

      msg_slack "Found email for #{first_name} #{last_name}"
    end
  end

  desc 'uploading contacts to customer.io'
  task :upload, [:number] => :environment do |_t, args|
    msg_slack("Uploading #{args[:number]} contacts to customer.io")

    $customerio = Customerio::Client.new(ENV['CUSTOMER_IO_SITE_ID'], ENV['CUSTOMER_IO_KEY'])

    contacts =  Contact.where(uploaded: false, invalid_email: false).where.not(email: nil).limit(args[:number])

    contacts.each do |contact|
      $customerio.identify(
        id: contact.email,
        email: contact.email,
        created_at: contact.created_at.to_i,
        last_name: contact.last_name,
        first_name: contact.first_name,
        title: contact.title,
        company: contact.company.name,
        url: contact.company.url,
        location: contact.company.location,
        timezone: contact.timezone,
        twitter: contact.twitter,
        linkedin_url: contact.linkedin_url,
        source: 'agent'
      )

      $customerio.track(contact.email, 'begin nurture')
      contact.update(uploaded: true)
    end
  end

  def msg_slack(msg)
    HTTParty.post(ENV['SLACK_URL'].to_s, body: { text: msg }.to_json)
  end
end
