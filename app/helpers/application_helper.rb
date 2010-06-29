# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # store an array of image locations
  # return random image location to display as logo
  def title_image
    location = ['logos/gO00y.gif', 'logos/pbfYE.gif']
    return location.sort_by{rand}.first
  end

end
