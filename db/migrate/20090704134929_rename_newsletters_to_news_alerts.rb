class RenameNewslettersToNewsAlerts < ActiveRecord::Migration
  def self.up
    rename_table 'newsletters', 'news_alerts'
  end

  def self.down
    rename_table 'news_alerts', 'newsletters'
  end
end
