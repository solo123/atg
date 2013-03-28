class PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      a_email = resource_params[:email]
      if a_email
        em = Email.where(:email_data_type => 'UserInfo').where(:email_address => a_email).first
        ui = em.email_data
        if ui
          unless ui.user
            u = User.new(:email => a_email)
            u.save
            ui.user = u
            ui.save
            self.resource = resource_class.send_reset_password_instructions(resource_params)
            if successfully_sent?(resource)
              respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
              return
            end
          end
        end
      end
      respond_with(resource)
    end
    
  end
end
