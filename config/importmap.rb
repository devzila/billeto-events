# Pin npm packages by running ./bin/importmap

pin "application"
pin "@clerk/clerk-js", to: "https://cdn.jsdelivr.net/npm/@clerk/clerk-js@5/dist/clerk.mjs"
pin "clerk_client", to: "clerk_client.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
