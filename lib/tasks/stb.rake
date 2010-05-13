namespace :stb do

    #===========================================================================
    #
    #  stb:admin_status
    #
    #===========================================================================

    desc 'Send admins an email about dai1y stats and pending fulfillments'
    task :admin_status => :environment do

        admins = User.find_all_by_user_type(User::ROLES[:administrator])
        #ENV['WWW_ROOT'] = 'http://www.shoptheblock.ca/'

        puts 'Sending administrator status mail'

        pending_fulfillments = User.needs_card.all
       
        admins.each do |admin|

            UserMailer.deliver_daily_status(
                admin,
                :pending_count => pending_fulfillments.length
            ) 

        end # each admin

        puts "Done!"

    end # task

    #===========================================================================
    #
    #  stb:renewal_reminders
    #
    #===========================================================================

    desc 'Send users an email when their account is close to expiring'
    task :renewal_reminders => :environment do

        puts "Checking for accounts that need to be renewed..."

        User.find_members_who_should_renew([30, 14,7]).each do |user|
            puts "Sending #{user.full_name} renewal notice"
            UserMailer.deliver_renewal_reminder(user)
        end

        puts "Done!"

    end #task

    #===========================================================================
    #
    #  stb:check_expired
    #
    #===========================================================================

    desc 'Check for expired accounts'
    task :check_expired => :environment do

        puts "Checking for expired accounts..."

        User.find_members_who_expired.each do |user|

            puts "Sending #{user.full_name} expiration notice"
            user.expire!
            UserMailer.deliver_account_expired(user)

        end # each expired user

        puts "Done!"

    end # task


    #===========================================================================
    #
    #  stb:send_gift_emails
    #
    #===========================================================================

    desc 'Check for gifts starting today and send email to gift recipient'
    task :send_gift_emails => :environment do

        puts "Checking for gifts starting today..."

        User.find_gifts_starting_today.each do |user|

            puts "Sending #{user.full_name} gift welcome message"
            UserMailer.deliver_gift_purchased(user)

        end # each gift recipient

        puts "Done!"

    end # task


    #===========================================================================
    #
    #  stb:daily
    #
    #===========================================================================

    desc 'Performs daily site tasks'
    task :daily => [:admin_status, :check_expired, :renewal_reminders, :send_gift_emails]

    desc "Show the date/time format strings defined and example output"
    task :date_formats => :environment do
        now = Time.now
        [:to_date, :to_datetime, :to_time].each do |conv_meth|
          obj = now.send(conv_meth)
          puts obj.class.name
          puts "=" * obj.class.name.length
          name_and_fmts = obj.class::DATE_FORMATS.map { |k, v| [k, %Q('#{String === v ? v : '&proc'}')] }
          max_name_size = name_and_fmts.map { |k, _| k.to_s.length }.max + 2
          max_fmt_size = name_and_fmts.map { |_, v| v.length }.max + 1
          name_and_fmts.each do |format_name, format_str|
            puts sprintf("%#{max_name_size}s:%-#{max_fmt_size}s %s", format_name, format_str, obj.to_s(format_name))
          end
          puts
        end
    end

end # stb
