# Cross-Origin Resource Sharing (CORS).
#
# In production the Angular app and this API may be served from different
# origins, so the browser needs explicit permission to call the API and to
# send the session cookie (credentials: true). Set FRONTEND_ORIGIN to the
# deployed frontend URL (comma-separated for more than one). Locally the Angular
# dev proxy makes requests same-origin, so CORS is effectively a no-op.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(ENV.fetch("FRONTEND_ORIGIN", "http://localhost:4200").split(","))

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
