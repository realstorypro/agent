class RemoveUnusedColumnsFromCompanies < ActiveRecord::Migration[7.0]
  def change
    remove_columns :companies, :scraped_company, :scraped_contacts
  end
end
