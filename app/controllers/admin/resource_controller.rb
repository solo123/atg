require 'core/action_callbacks'
module Admin
  class ResourceController < AdminController
    respond_to :html, :js, :json

    def index
      return @collection if @collection.present?
      load_collection
      invoke_callbacks(:index, :after)
    end
    def show
       load_object
       invoke_callbacks(:show, :after)
    end
    def edit
      load_object
      invoke_callbacks(:edit, :after)
    end
    def new
      @object = object_name.classify.constantize.new
      invoke_callbacks(:new_action, :after)
    end
    def update
      load_object
      @object.attributes = params[object_name.singularize.parameterize('_')]
      if @object.changed_for_autosave?
        @changes = @object.all_changes
        if @object.save
          invoke_callbacks(:update, :after)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
          @no_log = 1
        end
      end
    end
    def create
      @object = object_name.classify.constantize.new(params[object_name.singularize.parameterize('_')])
      invoke_callbacks(:create, :before)
      if @object.save
        invoke_callbacks(:create, :after)
      else
        flash[:error] = @object.errors.full_messages.to_sentence
        @no_log = 1
      end
    end
    def destroy
      load_object
      if @object.status && @object.status > 0
        @object.status = 0
      else
        @object.status = 1
      end
      @object.save
    end
    
    protected
      def load_collection
        params[:search] ||= {}
        @search = object_name.classify.constantize.metasearch(params[:search])
        pages = cfg.get_config(:admin_list_per_page) || "20"
        @collection = @search.page(params[:page]).per_page(pages.to_i)
      end 
      def load_object
        @object = object_name.classify.constantize.find(params[:id])
      end
      def object_name
        controller_name #.singularize
      end

      def flash_message_for(object, event_sym)
        resource_desc  = object.class.model_name.human
        resource_desc += " \"#{object.name}\"" if object.respond_to?(:name) && object.name.present?
        I18n.t(event_sym, :resource => resource_desc)
      end

      # Index request for JSON needs to pass a CSRF token in order to prevent JSON Hijacking
      def check_json_authenticity
        return unless request.format.js? or request.format.json?
        return unless protect_against_forgery?
        auth_token = params[request_forgery_protection_token]
        unless (auth_token and form_authenticity_token == URI.unescape(auth_token))
          raise(ActionController::InvalidAuthenticityToken)
        end
      end

    # URL helpers

      def new_object_url(options = {})
        if parent_data.present?
          new_polymorphic_url([:admin, parent, model_class], options)
        else
          new_polymorphic_url([:admin, model_class], options)
        end
      end

      def edit_object_url(object, options = {})
        if parent_data.present?
          send "edit_admin_#{model_name}_#{object_name}_url", parent, object, options
        else
          send "edit_admin_#{object_name}_url", object, options
        end
      end

      def object_url(object = nil, options = {})
        target = object ? object : @object
        if parent_data.present?
          send "admin_#{model_name}_#{object_name}_url", parent, target, options
        else
          send "admin_#{object_name}_url", target, options
        end
      end

      def collection_url(options = {})
        if parent_data.present?
          polymorphic_url([:admin, parent, model_class])
        else
          polymorphic_url([:admin, model_class])
        end
      end

      def invoke_callbacks(action, callback_type)
        callbacks = self.class.callbacks || {}
        return if callbacks[action].nil?
        case callback_type.to_sym
          when :before then callbacks[action].before_methods.each {|method| send method }
          when :after  then callbacks[action].after_methods.each  {|method| send method }
          when :fails  then callbacks[action].fails_methods.each  {|method| send method }
        end
      end      

      class << self
        attr_accessor :parent_data
        attr_accessor :callbacks

        def belongs_to(model_name, options = {})
          @parent_data ||= {}
          @parent_data[:model_name] = model_name
          @parent_data[:model_class] = model_name.to_s.classify.constantize
          @parent_data[:find_by] = options[:find_by] || :id
        end

        def new_action
          @callbacks ||= {}
          @callbacks[:new_action] ||= ActionCallbacks.new
        end

        def create
          @callbacks ||= {}
          @callbacks[:create] ||= ActionCallbacks.new
        end

        def edit
          @callbacks ||= {}
          @callbacks[:edit] ||= ActionCallbacks.new
        end

        def update
          @callbacks ||= {}
          @callbacks[:update] ||= ActionCallbacks.new
        end

        def destroy
          @callbacks ||= {}
          @callbacks[:destroy] ||= ActionCallbacks.new
        end
      end


  end
end
