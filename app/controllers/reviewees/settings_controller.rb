class Reviewees::SettingsController < Reviewees::BaseController
  skip_before_action :connect_github!
  
  def integrations
  end
end
