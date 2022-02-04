class RemoveExportedField < ActiveRecord::Migration[7.0]
  def change
    remove_column :companies, :exported
  end
end
