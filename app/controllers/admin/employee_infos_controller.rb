module Admin
	class EmployeeInfosController < ResourceController
    def docs
      unless has_auth('view_employee_document')
        flash[:error] = 'Unauthorised access to special page.'
        redirect_to :controller => 'admin/home', :action => :index 
      else
        load_collection
      end
    end
    def test_email
      UserMailer.test_email(current_employee.employee_info).deliver
      render :text => 'sent email'
    end
	end
end
