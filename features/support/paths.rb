module NavigationHelpers
  def path_to(page_name)
    begin
      page_name =~ /the (.*) page/
      path_components = $1.split(/\s+/)
      self.send(path_components.insert(0, 'admin').push('path').join('_').to_sym)
    rescue Object => e
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
