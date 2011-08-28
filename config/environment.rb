# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Monospace::Application.initialize!

Sass::Plugin.options[:template_location] = {
  "#{Rails.root}/app/stylesheets" => "#{Rails.root}/public/stylesheets"
}
