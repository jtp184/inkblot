# frozen_string_literal: true

require 'inkblot'

##=== For Displaying on the EPD ===##
# Inkblot::Buttons.init unless Inkblot::Buttons.ready?
# @t = 

# refresh_time = 60

# begin
#   loop do
#     Inkblot::Display.show(@t)
#     Inkblot::Buttons.get_press(refresh_time)

#     @t.refresh

#     puts
#     puts Time.now, @t.latest_report
#   end
# rescue IndexError
#   Inkblot::Display.clear
#   Inkblot::Buttons.release
#   exit
# end
