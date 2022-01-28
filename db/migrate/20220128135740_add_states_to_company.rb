class AddStatesToCompany < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :scraped_company, :boolean, default: false
    add_column :companies, :scraped_contacts, :boolean, default: false
  end
end
