class String
  def sort_normalize
    sub(/^\s*(the|an?)\s+/i,"").sub(/\W/,"").upcase
  end
end