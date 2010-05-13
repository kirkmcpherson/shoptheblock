class AddRecipientMethodToNewsAlerts < ActiveRecord::Migration
  def self.up
    add_column :news_alerts, :recipient_method, :string, :default => NewsAlert::ALL_RECIPIENTS
  end

  def self.down
    remove_column :news_alerts, :recipient_method
  end
end
