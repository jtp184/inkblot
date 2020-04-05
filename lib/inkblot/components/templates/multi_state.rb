module Inkblot
  module Templates
    module MultiState
      module ClassMethods
        def def_states(*sts)
          @states = sts
        end

        def default_state(st)
          @default_state_value = st
        end

        def default_state_value
          @default_state_value ||= states.first
        end

        def states
          @states
        end
      end

      def self.included(base)
        base.extend(MultiState::ClassMethods)
      end

      def state
        @state ||= self.class.default_state_value
      end

      def states
        @states = self.class.states
      end

      def state=(st)
        raise ArgumentError, "Not a valid state" unless states.include?(st)
        @state = st
      end

      def stateful_content
        return @stateful_content if @stateful_content
        @stateful_content = states.map { |s| [s, nil] }.to_h
      end

      def content_for_state(st, &blk)
        raise ArgumentError, "Not a valid state" unless states.include?(st)
        stateful_content[st] = blk.call
      end
    end
  end
end