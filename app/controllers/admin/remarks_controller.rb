module Admin
  class RemarksController < ResourceController
    def new
      @object = Remark.new
      if params[:todo_id]
        @object.note_data_type = 'Todo'
        @object.note_data_id = params[:todo_id]
      end
    end
    def create
      @object = Remark.new(params[:remark])
      @object.employee_info = current_employee.employee_info
      if params[:todo_id]
        @object.note_data_type = 'Todo'
        @object.note_data_id = params[:todo_id]
      end
      if @object.save
      else
        flash[:error] = @object.errors.full_messages.to_sentence
      end
    end
  end
end
