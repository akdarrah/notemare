class String
  
  def to_url
    return self.to_s.gsub(/ /, "+").gsub(/[’?-]/, "").gsub(/&/, "and").gsub(/é/, "e").titlecase
    # return CGI::escape(self)
  end
  
end