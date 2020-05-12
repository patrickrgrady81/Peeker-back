Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000'
    # origins '*'
    resource '*',
      headers: :any,
      :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],        
      methods: [:get, :post]
  end
end