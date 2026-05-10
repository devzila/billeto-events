class ApplicationController < ActionController::Base
  include Clerk::Authenticatable

  helper_method :clerk_display_label, :clerk_signed_in?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def clerk_display_label
    return unless clerk_signed_in?

    full = clerk.user
    label = full&.first_name&.presence || full&.username&.presence
    unless label
      addr = full&.email_addresses&.first
      label = addr.respond_to?(:email_address) ? addr.email_address : nil
    end

    label.presence || "Signed in"
  rescue StandardError
    "Signed in"
  end

  private

  def clerk_signed_in?
    clerk.user_id.present?
  end
end
