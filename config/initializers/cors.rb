# # Be sure to restart your server when you modify this file.

# # Avoid CORS issues when API is called from the frontend app.
# # Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# # Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development? || Rails.env.test?
      # localhost:3000 からのアクセスを許容する
      origins %w[http://localhost:3000]
    else
      origins 'http://habituation-quest.tk', 'https://habituation-quest.tk'
    end

    resource '*',
             headers: :any,
             expose: %w[access-token expiry token-type uid client],
             methods: %i[get post put patch delete options head]
  end
end
