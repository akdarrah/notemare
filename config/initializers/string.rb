class String
  
  # add + symbols in place of spaces for easily inserting into url
  def to_url
    return self.to_s.gsub(/ /, "+").gsub(/’/, "").titlecase
  end
  
end