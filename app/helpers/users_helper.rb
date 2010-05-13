module UsersHelper

  def search_distances
    Array.new(4){|i| [ sprintf("%dkm", (i+1)*5), (i+1)*5 ]}
  end

end
