module Inkblot
  module Components
    module Helpers
      # Easy mapping of methods to buttons
      module ButtonMap
        # The methods to add to the class
        module ClassMethods
          def def_button_methods(*btns)
            @button_methods = btns
          end

          def defined_button_methods
            @button_methods
          end
        end

        # Extends the +base+ class with the ClassMethods
        def self.included(base)
          base.extend(ButtonMap::ClassMethods)
        end

        # A default button actions based on those defined
        def button_actions
          @button_actions ||= self.class.defined_button_methods.map { |m| method(m) }
        end
      end
    end
  end
end
