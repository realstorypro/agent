namespace :list do
  list_loc = '/lists'

  desc 'builds a list from the clipboard'
  task build, [:number] => :environment do |_t, args|
    # set the folder where the import is stored
    @list_folder = "#{Dir.pwd}#{list_loc}/"

    prompt = TTY::Prompt.new

    prompt.warn '---------------------------'
    prompt.warn 'Welcome to the list builder'
    prompt.warn '---------------------------'

    @list_number = prompt.ask 'What is the list number?', convert: :int

    Dir.mkdir "#{@list_folder}#{@list_number}"

    def get_clipboard
      Clipboard.paste.encode('UTF-8')
    end

    def monitor_clipboard
      new_clipboard = get_clipboard

      if @clipboard != new_clipboard
        @clipboard = new_clipboard
        puts 'clipboard changed'

        match = @clipboard.scan(/\d+\.\n(?:.*\n){1}(.*)/)

        CSV.open("#{@list_folder}#{@list_number}/list_of_company_names_raw.csv", 'ab') do |csv|
          match.each do |company|
            csv << company
          end
        end

      end

      # recursive call
      sleep(0.05)
      monitor_clipboard
    end

    # set the initial clipboard value
    @clipboard = get_clipboard

    # start the recursion
    monitor_clipboard
  end

  desc 'uploads a list stored in a numbered folder'
  task upload, [:number] => :environment do |_t, args|
    # set the folder where the import is stored
    import_folder = Dir.pwd + list_loc + "/#{args[:number]}"

    # iterate through the companies
    CSV.foreach("#{import_folder}/list_of_company_names_raw.csv") do |row|
      # no double entries
      next if Company.where(name: row[0]).count.positive?

      # minimum 2 letters
      next if row[0].length < 2

      Company.find_or_create_by(name: row[0]) do |company|
        company.found = false
      end
    end
  end

end
