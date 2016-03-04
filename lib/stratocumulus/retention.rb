# encoding: UTF-8
#
module Stratocumulus
  class Retention
    def initialize(schedule)
      @schedule = schedule
    end

    def rule(key)
      return unless expires_in_days

      {
        "ID" => key,
        "Prefix" => key,
        "Enabled" => true,
        "Days" => expires_in_days,
      }
    end

    def upload_today?
      !@schedule || relevent_period
    end

    private

    def expires_in_days
      return unless @schedule

      relevent_period * @schedule[relevent_period]
    end

    def relevent_period
      @schedule.keys.sort.reverse.find do |period|
        0 == Date.today.yday % period
      end
    end
  end
end
