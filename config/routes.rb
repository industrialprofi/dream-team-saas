Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: 'pages#home'

  # GoodJob Web UI for background jobs monitoring
  if Rails.env.production?
    # Protect with Basic Auth in production using env vars
    good_job_constraint = lambda do |request|
      auth = Rack::Auth::Basic::Request.new(request.env)
      username = ENV.fetch('GOOD_JOB_DASHBOARD_USER', nil)
      password = ENV.fetch('GOOD_JOB_DASHBOARD_PASSWORD', nil)
      next false unless auth.provided? && auth.basic? && username && password

      ActiveSupport::SecurityUtils.secure_compare(auth.credentials[0].to_s, username.to_s) &&
        ActiveSupport::SecurityUtils.secure_compare(auth.credentials[1].to_s, password.to_s)
    end

    constraints(good_job_constraint) do
      mount GoodJob::Engine => '/admin/good_job'
    end
  else
    mount GoodJob::Engine => '/admin/good_job'
  end
end
