# frozen_string_literal: true
class PeriodsSerializer < Serializer
  class << self
    def dump_as_json(periods)
      periods.collect do |period|
        [period.type, period.starts_at.to_i, period.ends_at.to_i]
      end
    end

    def load_as_json(serialized_periods)
      serialized_periods.collect do |serialized_period|
        Period.new(
            type: serialized_period[0],
            starts_at: serialized_period[1],
            ends_at: serialized_period[2],
        )
      end
    end
  end
end
