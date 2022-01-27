class Contact < ApplicationRecord
  belongs_to :company
  jsonb_accessor  :fields,
                  title: :string,
                  lat: :string,
                  lng: :string,
                  timezone: :string

end
