module Timber
  module Probes
    class ActionViewLogSubscriber < Probe # :nodoc:
      def initialize
        require "action_view/log_subscriber"
        require "timber/probes/action_view_log_subscriber/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if Util::ActiveSupportLogSubscriber.subscribed?(:action_view, LogSubscriber)
        Util::ActiveSupportLogSubscriber.unsubscribe(:action_view, ::ActionView::LogSubscriber)
        LogSubscriber.attach_to(:action_view)
      end
    end
  end
end