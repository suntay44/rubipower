// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { UltimateTurboModalController } from "ultimate_turbo_modal"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)
application.register("modal", UltimateTurboModalController)

// Debug: Check if Ultimate Turbo Modal is loaded
console.log("Ultimate Turbo Modal Controller:", UltimateTurboModalController);
console.log("Application controllers:", application.router.modulesByIdentifier);
