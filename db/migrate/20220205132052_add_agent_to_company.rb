class AddAgentToCompany < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :agent, :string, default: nil
  end
end
