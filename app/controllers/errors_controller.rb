class ErrorsController < ApplicationController
  def not_found
    render 'error_404', status: 404, formats: %i(html)
  end

  def internal_server_error
    render 'error_500', status: 500, formats: %i(html)
  end
end