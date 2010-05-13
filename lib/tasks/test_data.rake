
namespace :data do

    #***************************************************************************
    #
    #   Constants
    #
    #***************************************************************************

    CATEGORIES = {
        :arts       => "Arts & Crafts and Ceramic Studios",
        :babyproofing => "Babyproofing",
        :bakeries   => "Bakeries and Coffee Shops",
        :bakers     => "Bakers",
        :birthday   => "Birthday Party Venues",
        :butcher    => "Butcher Shop",
        :camps      => "Camps",
        :car_wash   => "Car Wash",
        :caterer    => "Caterers",
        :child_class => "Children’s Classes",
        :child_clothing => "Children’s Clothing Stores",
        :child_furniture => "Children's Furniture & Accessories",
        :child_shoe => "Children's Shoe Stores",
        :clothing   => "Clothing Stores for Women",
        :counsel    => "Counseling/Psychotherapy",
        :dental     => "Dental Services",
        :diet       => "Dieticians",
        :laundry    => "Dry Cleaning/Laundry Services",
        :child_entertainment => "Entertainment for Children's Parties",
        :financial_legal => "Financial/Legal Services",
        :furniture  => "Furniture & Home Accessories",
        :design     => "Graphic Design/Website Design",
        :groceries  => "Grocery Stores",
        :hardware   => "Hardware Stores",
        :renovation => "Home Renovation & Design",
        :ice_cream  => "Ice Cream, Chocolate & Candy Stores",
        :in_home    => "In-Home Services",
        :invitations => "Invitations & Stationary",
        :make_up    => "Make-Up Artists",
        :maternity  => "Maternity Stores",
        :medical    => "Medical Services",
        :nanny      => "Nanny Placement Services",
        :party_supply => "Party Supply Stores",
        :training   => "Personal Training/Small Group Training Studio",
        :persnalized => "Personalized Services",
        :pets       => "Pet Stores & Supplies",
        :photo      => "Photographers",
        :prenatal_services => "Prenatal/Postnatal Classes & Services",
        :preschool  => "Preschool Programs",
        :prenatal_yoga => "Prenatal/Postnatal Yoga",
        :real_estate => "Real Estate",
        :restaurants => "Restaurants",
        :salons     => "Salons, Spas & Aesthetic Services",
        :sports     => "Sports Equipment",
        :swimming   => "Swimming Schools", 
        :toys       => "Toy Stores"
    }

    #***************************************************************************
    #
    #   clean
    #
    #***************************************************************************

    desc "Removes existing site data"
    task :clean => :environment do
        puts "=====>> Removing existing site data"

        begin
            
            puts "=====>> Recreating database"
            Rake::Task["db:drop"].execute
            Rake::Task["db:create"].execute
            
            puts "=====>> Migrating to current version"
            Rake::Task["db:migrate"].execute

        rescue
            puts "WARNING: Clean failed with exception: #{$!}"
            raise
        end
    end

    task :init => [:clean, :categories, :accounts]

    #***************************************************************************
    #
    #   categories
    #
    #***************************************************************************

    task :categories => :clean do

        CATEGORIES.each_value do |v|
            Category.create!(:name => v)
        end
    
    end

    #***************************************************************************
    #
    #   accounts
    #
    #***************************************************************************

    task :accounts => :clean do

        user = User.new(
            :email => 'admin@shoptheblock.ca',
            :password => 'bbbbbb',
            :password_confirmation => 'bbbbbb',
            :neighbourhood_location => '4711 yonge st, toronto, ontario, M2N 6K8'
        )
        user.role = :administrator
        user.shipping_postalcode = "test"
        user.shipping_province = "test"
        user.shipping_city = "test"
        user.shipping_address = "test"
        user.shipping_country = "test"
        user.save!
    end

    #***************************************************************************
    #
    #   load
    #
    #***************************************************************************

    desc "Load site with test data"
    task :load => :init do

        puts "=====>> Creating test data"
    
        begin

            root = File.dirname(__FILE__)
            puts "Root directory is #{root}"

            groceries = Category.find_by_name(CATEGORIES[:groceries])
            camps = Category.find_by_name(CATEGORIES[:camps])
            arts = Category.find_by_name(CATEGORIES[:arts])
            clothing = Category.find_by_name(CATEGORIES[:clothing])


            user = User.new(
                :first_name => 'Joe',
                :last_name => 'Smith',
                :email => 'joe@brightspark3.com',
                :password => 'aaaaaa',
                :password_confirmation => 'aaaaaa',
                :neighbourhood_location => '172 Douglas Ave, Toronto, Ontario',
                :category_ids => [groceries, clothing]
            )
            user.membership_expiration = Time.zone.now.advance(:months => 12)
            user.shipping_postalcode = "test"
            user.shipping_province = "test"
            user.shipping_city = "test"
            user.shipping_address = "test"
            user.shipping_country = "test"
            user.save!

            m = Merchant.create!(
                :name => 'Pusateri\'s Fine Foods',
                :categories => [groceries],
                :description => 'Lots of food and stuff',
                :web_site => 'http://www.pusateris.com'
            )

            Store.create!(
                :merchant => m,
                :location => '1539 Avenue Road, Toronto, ON',
                :hours => 'mon-fri=0900-1700 sat=1000-1800',
                :phone => '(416) 555-1111'
            )

            Promotion.create!(
                :merchant_id => m.id,
                :headline => '10% off caviar for next 3 days',
                :start_date => Time.now,
                :end_date => Time.now + 3.days,
                :promotion_type => Promotion::Type[:promotion]
            )

            #m.logo.assign(File.new(File.join(root, 'xyz_logo.png')))
            #m.save!

            m = Merchant.create!(
                :name => 'Ritche Camps',
                :categories => [camps],
                :description => 'summer camp',
                :stores => [
                    Store.new(
                        :location => '1662 Avenue Road, Toronto, ON',
                        :hours => 'mon-fri=0800-2200',
                        :phone => '(416) 555-2222'
                    ),
                    Store.new(
                        :location => '341 Lawrence Ave W, Toronto, Ontario',
                        :hours => 'mon-fri=0800-2200',
                        :phone => '(416) 555-3333'
                    )
                ]
            )

            Promotion.create!(
                :merchant_id => m.id,
                :store => m.stores[0],
                :headline => '10% off for summer events',
                :promotion_type => Promotion::Type[:discount]
            )

            m = Merchant.create!(
                :name => 'Art Emporium',
                :categories => [arts],
                :description => 'art and stuff',
                :stores => [
                    Store.new(
                        :location => '250 Lawrence W, Toronto, ON',
                        :phone => '(416) 555-9999',
                        :hours => 'mon-fri=1100-1500 sat=1200-1800'
                    )
                ]
            )

            Promotion.create!(:merchant_id => m.id, :headline => '5% off Nike shoes', :promotion_type => Promotion::Type[:discount])

            m = Merchant.create!(
                :name => 'Forever 21',
                :categories => [clothing],
                :description => 'Clothes and stuff',
                :web_site => 'http://www.forever21.com',
                :stores => [
                    Store.new(
                        :location => '50 Woburn Ave, Toronto, ON',
                        :phone => '(416) 555-0000',
                        :hours => 'mon-wed=0900-1800 fri-sat=0900-2200'
                    )
                ]
            )

            Promotion.create!(:merchant_id=>m.id, :headline => '2 for 1 Tuesdays', :promotion_type => Promotion::Type[:discount])

        rescue
            puts "Reverting due to exception: #{$!} at #{$@}"
            Rake::Task["data:clean"].execute()
            raise
        end

    end

end

namespace :db do

  task :backup => :environment do
    RAILS_DEFAULT_LOGGER.auto_flushing = true
    puts "***** Start rake db:backup *****"
    db_config     = YAML::load(ERB.new(IO.read('config/database.yml')).result)[RAILS_ENV]
    #s3_config     = YAML::load(open('config/amazon_s3.yml'))[ENV['RAILS_ENV']]

     DB_DATABASE = db_config['database']
     DB_USER = db_config['username']
     DB_PASS = db_config['password']

     #ACCESS_KEY = s3_config['access_key_id']
     #SECRET_KEY = s3_config['secret_access_key']
     #S3_BUCKET  = s3_config['bucket_name']

     BACKUP_FILENAME = "#{DB_DATABASE}_backup_1.sql.gz"

     puts "Backing up...#{BACKUP_FILENAME}"
     `rm #{DB_DATABASE}_backup_3.sql.gz`
     [2,1]. each do |i|
       `mv #{DB_DATABASE}_backup_#{i}.sql.gz #{DB_DATABASE}_backup_#{i+1}.sql.gz`
     end
     mysqldumpcmd = "mysqldump --user=#{DB_USER} --password=#{DB_PASS} --opt #{DB_DATABASE} | gzip > #{BACKUP_FILENAME}"
     `#{mysqldumpcmd}`

=begin
     say "Uploading backup to S3..."
     @s3 = RightAws::S3.new(ACCESS_KEY,SECRET_KEY)
     @bucket = @s3.bucket('istopover')
     @bucket.put("#{ENV['RAILS_ENV']}/dbbackups/#{BACKUP_FILENAME}", open("#{BACKUP_FILENAME}") )
=end

     puts "***** Completed rake db:backup *****"
   end

end

namespace :stb do

  desc 'Dumps samples of all emails in HTML and text formats'
  task :dump_emails => :environment do

    ENV['WWW_ROOT'] = 'http://www.shoptheblock.ca/'

    dir = File.join(File.dirname(__FILE__), 'email_dump')
    if File.exists?(dir)
      Dir.glob("*.{html,txt}") { |filename| File.unlink(filename) }
    else
      Dir.mkdir(dir)
    end

    templates = [
      'account_expired',
      'daily_status',
      'forgot_password',
      'lost_card',
      'referral_mail',
      'renewal_reminder',
      'signup_notification',
      'site_news'
    ].each do |template|

      puts "Dumping email #{template}"

      user = User.new(
        :first_name => 'Agnes',
        :last_name => 'Smith',
        :email_format => User::EmailFormat[:text]
      )
      user.id = 1
      user.user_type = User::ROLES[:newsletter_only]
      user.membership_expiration = Time.zone.now + 2.days
      user.activation_code = 'ABCDEFG123456'
      user.password_reset_code = 'ABCDEFG123456'
      args = ["create_#{template}", user]

      case template
      when 'daily_status'
        args << { :pending_count => 5 }
      when 'referral_mail'
        args << ['Ford Prefect <referrer@example.com>']
      when 'site_news'
        args << "Sample NewsAlert"
        args << %{
Here is my sample news alert!!

Here is a new paragraph with a link to http://www.example.com!

Here is another one telling you to email info@shoptheblock.ca!
}
      end

      mail = UserMailer.send(*args)
      File.open(File.join(dir, "#{template}.txt"), "w+") do |f|
        f << mail
      end

      unless ['daily_status'].include?(template)

        user.email_format = User::EmailFormat[:html]
        mail = UserMailer.send(*args)
        File.open(File.join(dir, "#{template}_html.txt"), "w+") do |f|
          f << mail
        end

        File.open(File.join(dir, "#{template}_body.html"), "w+") do |f|
          f << mail.parts[0].body
        end
        
      end
      
    end

    puts 'Done.'

  end

end

