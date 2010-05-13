class RenameRecipientsByCategoryToRecipientMethod < ActiveRecord::Migration

  def self.up
    change_column :newsletters, :recipients_by_category, :string, :default => Newsletter::ALL_RECIPIENTS
    rename_column :newsletters, :recipients_by_category, :recipient_method
  end

  def self.down
    rename_column :newsletters, :recipient_method, :recipients_by_category
    change_column :newsletters, :recipients_by_category, :boolean
  end

end
