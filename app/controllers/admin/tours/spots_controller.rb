module Admin
  class Tours::SpotsController < ResourceController
    create.before :add_tour_id

    def new
      load_parent
      @object = @tour.spots.build
    end
    def create
      load_parent
      @object = @tour.spots.build(params[:spot])
      @tour.save
    end

    def show
      # set tour icon
      load_object
      @object.tour.title_photo = @object.destination.title_photo
      @object.tour.save
    end
    def destroy
      @object = Spot.find(params[:id])
      @object.destroy
    end

    def add_tour_id
      @object.tour_id = params[:tour_id].to_i
    end
    private
      def load_collection
        load_parent
        @collection = @tour.spots
      end 
      def load_object
        load_parent
        @object = Spot.find(params[:id])
      end
      def load_parent
        @parent = @tour = Tour.find(params[:tour_id])
      end
 
  end
end

