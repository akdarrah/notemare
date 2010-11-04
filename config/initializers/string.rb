# coding: utf-8
class String
  
  def to_url
    return self.to_s.gsub(/ /, "+").gsub(/[’?-]/, "").gsub(/&/, "and").titlecase
    # return CGI::escape(self)
  end
  
end