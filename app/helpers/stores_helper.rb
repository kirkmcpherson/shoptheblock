module StoresHelper

    class HoursItem

        attr_reader :start_day
        attr_reader :end_day
        attr_reader :start_hour
        attr_reader :start_minute
        attr_reader :end_hour
        attr_reader :end_minute
        attr_reader :by_appointment
        attr_reader :close



        def initialize(info)

            @start_day      = day_from_param(info[0])
            @end_day        = day_from_param(info[1], @start_day)

            if info.length > 2
                @start_hour     = info[2].to_i
                @start_minute   = info[3].to_i
                @end_hour       = info[4].to_i
                @end_minute     = info[5].to_i
            end
            @by_appointment =  info[6]
            @close                     =  info[7]

        end

        def closed?          
            !@close.blank?
        end

        def by_appointment?
          !@by_appointment.blank?
        end

        def has_hours?
            return false  if @start_hour == 0 &&  @start_minute == 0 &&  @end_hour == 0 && @end_minute== 0

            return true
        end
        

    private

        def day_from_param(param, default=nil)
            
            if param.nil? && !default.nil?
                default
            elsif param.is_a?(String)
                StoreHours::DAY_STRINGS.index(param)
            elsif param.is_a?(Integer)
                param
            else
                throw ArgumentError.new
            end

        end

    end

    class StoreHours

        DAY_STRINGS     = %w{mon tue wed thu fri sat sun}
        DAYS_PATTERN    = "(?:#{DAY_STRINGS.join('|')})"
        TIME_PATTERN    = "((?:0?[0-9]?)|(?:1[0-9]?)|(?:2[0-3]?))([0-5][0-9]?)"
        BY_APPOINTMENT   = "((?:[A]?))"
        CLOSE   = "((?:[C]?))"
        SINGLE_PATTERN  = "(#{DAYS_PATTERN})(?:-(#{DAYS_PATTERN}))?=#{TIME_PATTERN}-#{TIME_PATTERN}#{BY_APPOINTMENT}#{CLOSE}"
        PATTERN         = "\\A#{SINGLE_PATTERN}(?:\s#{SINGLE_PATTERN})*\\Z"

        Pattern         = Regexp.new(PATTERN)
        SinglePattern   = Regexp.new("\\A#{SINGLE_PATTERN}\\Z")

        attr_reader :hours_string

        def initialize(input)

            if input.nil?
                @hours_string = ''
            elsif input.is_a?(String)
                #puts "Creating new from #{str}"
                @hours_string = input
            else
                throw ArgumentError.new('Invalid argument type to StoreHours constructor')
            end
        end

        def items
            items = []

            @hours_string.split(' ').each do |s|
                matches = SinglePattern.match(s).captures
                items << HoursItem.new(matches)
            end

            full_items = []           
          
           items = items.sort{|x,y| x.start_day <=> y.start_day }.each do |x|
                unless full_items.empty?                  
                     if (x.start_day - full_items.last.end_day) > 1
                         full_items << HoursItem.new([full_items.last.end_day+1, x.start_day-1])
                      end
                end
            
                full_items << x            
            end
        
          if full_items.blank?
             return  full_items 
           end          
          
          return full_items

        end

        def self.to_hours(obj)
            #puts "Converting #{str}"
            StoreHours.new(obj)
        end

         def self.get_hours  item

            if item[:enable_hours].to_i  == 1
              return  sprintf("%02d%02d-%02d%02d", item[:start_hour].to_i,  item[:start_minute].to_i,  item[:end_hour].to_i,item[:end_minute].to_i)
            end

            return   sprintf("%02d%02d-%02d%02d",0,0,0,0)

        end

        def self.check_close_or_by_appointment item

          return  sprintf("%s","C") unless item[:close].blank?

          return  sprintf("%s","A") unless item[:by_appointment].blank? 

        end

        def self.from_form(input)

          # start_day0end_day4end_minute0start_hour9start_minute0end_hour19  - example no hours appointment
          # by_appointmentAstart_day0end_day4end_minute0start_hour9start_minute0end_hour19 -example hours by appointment

          #enable_hours1by_appointmentAstart_day0end_day6end_minute0closeCstart_hour0start_minute0end_hour0
          #Must be able to support
          #Mon - Friday 9am - 5pm
          #Mon - tuesday 7m - 9pm by appointment only
          #Sat by appoinment only
          #Sunday closed

            hours_string = ''
            input.each do |item|
                hours_string += ' ' unless hours_string.empty?               
                hours_string += sprintf(
                                    "%s-%s=%s%s",
                                    DAY_STRINGS[item[:start_day].to_i],
                                    DAY_STRINGS[item[:end_day].to_i],StoreHours.get_hours(item),
                                    StoreHours.check_close_or_by_appointment(item))

            end

            return StoreHours.new(hours_string)
            
        end

    end




    def hours_from_form(val)
        return StoreHours.from_form(val)
    end

   

end
