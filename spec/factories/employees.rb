FactoryGirl.define do
  factory :employee_info do
  end
  factory :company do
  end

  factory :admin_employee, class: Employee do
    login_name 'test'
    email 'test@aetravelusa.com'
    password 'aetravelusa.com'
    password_confirmation 'aetravelusa.com'
  end
  factory :admin_employee_info, class: EmployeeInfo do
    association :employee, factory: :admin_employee 
    nickname 'admin employee'
    status 1
  end
end


