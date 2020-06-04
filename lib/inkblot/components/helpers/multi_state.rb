module Inkblot
  module Components
    module Helpers
      # Adds methods for storing multiple states and different content
      # for each one.
      module MultiState
        # The methods to add to the class
        module ClassMethods
          # Define states from symbols +sts+
          def def_states(*sts)
            @states = sts
          end

          # Set the default state directly to +st+
          def default_state(st)
            @default_state_value = st
          end

          # Returns the value set by default state, or the first state
          # if it was not set
          def default_state_value
            @default_state_value ||= states.first
          end

          # Attribute reader for the states variable
          def states
            @states
          end
        end

        # Extends the +base+ class with the ClassMethods
        def self.included(base)
          base.extend(MultiState::ClassMethods)
        end

        # The current state, defaults to the default_state_value if not set
        def state
          @state ||= self.class.default_state_value
        end

        # The instance-level states, defaulting to the ones set on the class
        def states
          @states ||= self.class.states
        end

        # Sets the current state to +st+ if it exists within the states
        def state=(st)
          raise ArgumentError, 'Not a valid state' unless states.include?(st)

          @state = st
        end

        # Holds a hash of states and their content
        def state_content
          return @state_content if @state_content

          @state_content = states.map { |s| [s, nil] }.to_h
        end

        # Convinience method. If +st+ is given it returns the data for
        # that state, and if not it uses the current state. Providing a block
        # sets the content into the array instead of retrieving it
        def content_for_state(st = nil)
          if !st.nil? && !states.include?(st)
            raise ArgumentError, 'Not a valid state'
          end

          st ||= state

          if block_given?
            state_content[st] = yield
          else
            state_content[st]
          end
        end
      end
    end
  end
end
