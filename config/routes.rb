Omei::Application.routes.draw do
  devise_for :employees, :skip => [:registrations]
    as :employee do
      get '/employees/edit' => 'devise/registrations#edit', :as => 'edit_employee_registration'
      put 'employees' => 'devise/registrations#update', :as => 'employee_registration'
    end
  devise_for :users, :controllers => {:passwords => 'passwords'}
  root :to => 'home#index'
  match 'home(/:action)' => 'home'
  resources :destinations, :pages, :tour_orders

  resources :tours do
    member do
      get 'order'
      post 'order'
    end
    match 'order' => 'orders#new', :via => :get
    match 'order' => 'orders#edit', :via => :post
    match 'prices' => 'orders#prices'
  end

  namespace :admin, :path => 'omeiadmin' do
    resources :destinations do
      resources :photos do
        member do
          get :cover
        end
      end
    end
    resources :pages
    resources :buses do
      resources :photos do
        get :cover, :on => :member
      end
      resources :bus_reserved_dates
      get :shifts, :on => :member
    end
    resources :tours do
      resources :spots, :controller => 'tours/spots'
      collection do
        get 'search'
      end
    end
    resources :schedules do
      collection do
        get :select, :search, :generate
        put :selected
      end
      member do
        get :orders
      end
      resources :schedule_assignments do
        resources :bus_seats
        put :seats, :on => :member
      end
    end
    resources :user_infos do
      collection do
        get :select, :search, :add_tel, :add_email, :add_address, :brief
      end
      resources :photos do
        get :cover, :on => :member
      end
    end
    resources :emails, :telephones, :addresses
    resources :orders do
      get :add_room, :on => :collection
      resources :remarks
    end
    resources :employee_infos do
      resources :photos do
        get :cover, :on => :member
      end
      resources :accounts
      get :docs, :on => :collection
      get :test_email, :on => :member
      get :edit_info, :on => :member
    end
    resources :companies do
      get 'add_contact', :on => :collection
      resources :photos do
        get :cover, :on => :member
      end
      resources :accounts 
      get :new_invoice, :on => :member 
    end
    resources :payments do
      get :refund, :on => :collection
    end
    resources :vouchers, :company_receivables
    resources :pay_cashes, :pay_credit_cards, :pay_checks, :pay_companies, :pay_vouchers
    resources :accounts do
      get :company, :on => :collection
      get :pay, :on => :member
    end
    resources :bills, :invoices
    resources :telephones, :emails, :addresses
    resources :input_types, :tour_types, :positions
    resources :schedule_assignment_costs, :schedule_assignment_balances
    resources :logs
    resources :todos do
      get 'zone', :on => :collection
      resource :remarks
      member do
        get 'add_employee'
        post 'add_worker'
        delete 'rm_worker'
      end
    end
    resources :my_logs do
      get :zone, :on => :collection
    end
    resources :app_configurations do
      collection do
        get :reload
      end
    end
    resources :remarks
    resources :cities do
      get :select, :on => :member
      get :get_detail, :on => :member
      get :search, :on => :collection
    end
    resources :auths, :employees;
  end

  match '/omeiadmin', :to => 'admin/home#index', :as => :omeiadmin
  match 'barcode/:str' => 'barcode#gen'
  match ':controller/:id/:action', :controller => /admin\/[^\/]+/ 

end
