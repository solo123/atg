module Admin
  class DestinationsController < ResourceController
    new_action.after :add_description
    edit.after :add_description

    def show
      load_object
    end

    protected
    def load_collection
      params[:search] ||= {}
      @search = Destination.metasearch(params[:search])
      pages = cfg.get_config(:admin_list_per_page) || "20"
      @collection = @search.paginate(:page => params[:page], :per_page => pages).includes([:city])
    end

    def add_description
      unless @object.description
        @object.build_description
      end
    end

  end
end
