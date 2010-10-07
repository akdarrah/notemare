ActionController::Routing::Routes.draw do |map|
  map.root :controller => "artist"
  
  map.connect ':id', :controller => 'artist', :action => 'lookup'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
