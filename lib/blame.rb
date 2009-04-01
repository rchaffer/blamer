module Blame
  module Userstamp
    def self.included(base)
      base.alias_method_chain :create, :userstamps
      base.alias_method_chain :update, :userstamps
      
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def record_userstamps=(value)
        Thread.current[:blame_disabled] = !value
      end
      
      def disabled?
        Thread.current[:blame_disabled]
      end
      
      def enabled?
        !disabled?
      end
    end
    
    private
    
    def userstamp_object
      Thread.current[:current_user]
    end
    
    def create_with_userstamps
      if enabled? && userstamp_object
        write_attribute('created_by', userstamp_object.id) if respond_to?(:created_by)
        write_attribute('updated_by', userstamp_object.id) if respond_to?(:updated_by)
      end
      create_without_userstamps
    end
    
    def update_with_userstamps(*args)
      if enabled? && userstamp_object && (!partial_updates? || changed?)
        write_attribute('updated_by', userstamp_object.id) if respond_to?(:updated_by)
      end
      update_without_userstamps
    end
    
    def enabled?
      !Thread.current[:blame_disabled]
    end
    
  end
  
  module UserstampMigrationHelper
    def userstamps
      column :created_by, :integer
      column :updated_by, :integer
    end
  end
  
end