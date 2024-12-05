# This migration comes from geoblacklight_admin (originally 20241120238823)
class RenameReferencesToDistributions < ActiveRecord::Migration[7.2]
  def change
    rename_table :document_references, :document_distributions
  end
end