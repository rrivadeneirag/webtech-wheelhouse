# Cross-Origin Resource Sharing for the price-list page, which is served from an
# origin that is not the API's. Only the page's two origins are allowed — the
# published GitHub Pages site and the local server used while developing — never
# "*". Only the public services routes the page reads are opened; the
# token-protected routes (repairs, creating a service) are not shared with any
# origin. A request with no Origin header (curl, a program) is unaffected: CORS
# is a rule for browsers only.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://rrivadeneirag.github.io",
            "http://localhost:8000",
            "http://127.0.0.1:8000"

    resource "/api/v1/services",   methods: %i[get], headers: :any
    resource "/api/v1/services/*", methods: %i[get], headers: :any
  end
end
