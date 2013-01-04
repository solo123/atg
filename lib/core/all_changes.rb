module ActiveRecord
  class Base
    def all_changes
      changes = []
      changes << self.changes if self.changed?
      self.class.reflect_on_all_autosave_associations.each do |ass|
        if ass.macro == :has_one
          ass_obj = self.send(ass.name)
          if ass_obj
            changes << ass_obj.changes if ass_obj.changed?
          end
        elsif ass.macro == :has_many
          self.send(ass.name).each do |ass_obj|
            if ass_obj
              changes << ass_obj.changes if ass_obj.changed?
              changes << "[DELETE]#{ass_obj.inspect}" if ass_obj.marked_for_destruction?
            end
          end
        end
      end

      changes
    end
  end
end

