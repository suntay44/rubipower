# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js", integrity: "sha384-NStGXzUH4pFNGrLRkzXYz7zzDn8S6MvFPwfKSuYf6TlX25BrNVP4oCN2S04XUuOI" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "ultimate_turbo_modal", integrity: "sha384-pn0+/jb5oPj5KLv+UIMg61DKhXkbQRvfgDHkpHXETtHU2vVpmJQ1153tOHMgbB+B" # @2.2.1
