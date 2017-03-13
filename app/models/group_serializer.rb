# frozen_string_literal: true
class GroupSerializer < Serializer
  class << self
    def dump_as_json(group)
      [group.number, PeriodsSerializer.dump_as_json(group.periods)]
    end

    def load_as_json(serialized_group)
      Group.new(number: serialized_group[0], periods: PeriodsSerializer.load_as_json(serialized_group[1]))
    end
  end
end
