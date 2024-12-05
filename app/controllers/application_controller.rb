class ApplicationController < ActionController::Base
  include Pagy::Backend
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
        before_action :allow_geoblacklight_params

        def allow_geoblacklight_params
          # Blacklight::Parameters will pass these to params.permit
          blacklight_config.search_state_fields.append(Settings.GBL_PARAMS)
        end
end
