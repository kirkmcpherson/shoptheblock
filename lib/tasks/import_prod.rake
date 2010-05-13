namespace 'db' do
  
  desc 'Imports data from production db on slicehost to local dev db.'
  task :import_prod, :needs => :environment do |t|
    # dump
    sh "ssh deploy@67.23.33.108 'mysqldump --user=root --password=ShoptheBlockcZR7kN ShopTheBlock_production > /tmp/stb_production.backup.sql'"

    # tar
    sh "ssh deploy@67.23.33.108 'cd /tmp && tar cjf stb_production.backup.sql.tar.bz2 stb_production.backup.sql'"

    # transfer
    sh "scp deploy@67.23.33.108:/tmp/stb_production.backup.sql.tar.bz2 ."

    # extract
    sh "tar xjf stb_production.backup.sql.tar.bz2"

    sh "mysql --user=root ShopTheBlock_development < stb_production.backup.sql"

    # clean up
    sh "rm stb_production.backup.sql*"
    sh "ssh deploy@67.23.33.108 'rm /tmp/stb_production.backup.sql.tar.bz2'"
  end
  
end
