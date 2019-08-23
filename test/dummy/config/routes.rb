Rails.application.routes.draw do
  mount CloudDriver::Engine => "/cloud_driver"
end
