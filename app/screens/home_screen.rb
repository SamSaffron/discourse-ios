class HomeScreen < UIViewController
  extend IB

  outlet :table, UITableView
  outlet :search_bar, UISearchBar
  outlet :forum_cell, HomeScreenForumCell

  def viewDidLoad
    super
    self.title = "Discourse"
    self.view.backgroundColor = UIColor.discourse_red
    self.search_bar.placeholder = "Add Site"
    self.search_bar.showsCancelButton = false
    self.search_bar.delegate = self
    @in_search = false
    @search_term = ""
    @mutex = Mutex.new
  end

  def searchBar(search_bar, textDidChange: text)
    if text =~ /.+\..+/
      attempt_to_resolve(text)
    end
  end

  def perform_search
    @thread ||= Thread.new do
      current_term = ""
      done = false

      while true
        @mutex.synchronize do
          if current_term == @search_term
            done = true
            @thread = nil
          else
            current_term = @search_term
          end
        end
        break if done

        # debounce
        should_retry = false
        while should_retry
          sleep 0.2
          @mutex.synchronize do
            should_retry = current_term != @search_term
          end
        end

        site = Site.search(@search_term)
        @mutex.synchronize do
          @site = site
          p site
        end
      end
    end
  end

  def attempt_to_resolve(text)
    @mutex.synchronize do
      @search_term = text
      perform_search
    end
  end

  def searchBarTextDidBeginEditing(search_bar)
    switch_to_search
  end

  def searchBarTextDidEndEditing(search_bar)
    self.search_bar.showsCancelButton = false
  end

  def searchBarCancelButtonClicked(search_bar)
    search_bar.text = ""
    switch_from_search
  end

  def searchBarSearchButtonClicked(search_bar)
    switch_from_search
  end

  def switch_to_search
    @in_search = true
    self.search_bar.showsCancelButton = true
    self.table.reloadData
  end

  def switch_from_search
    @in_search = false
    self.search_bar.showsCancelButton = false
    self.table.reloadData
  end


  def tableView(table_view, numberOfRowsInSection:section)
    if @in_search
      0
    else
      Site.count
    end
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    site = Site[index_path.row]
    cell = table_view.dequeueReusableCellWithIdentifier("HomeScreenForumCell", forIndexPath: index_path)
    cell.textLabel.text = site.name
    cell.detailTextLabel.text = site.url

    if site.unreadTotal && site.unreadTotal > 0
      label = UILabel.alloc.initWithFrame(CGRectMake(10,10,10,10))
      label.text = site.unreadTotal.to_s
      label.sizeToFit
      cell.accessoryView = label
    end

    cell
  end

  def prepareForSegue(segue, sender:sender)
    case segue.identifier
    when "show_discourse_screen"
      index_path = self.table.indexPathForSelectedRow
      controller = segue.destinationViewController
      controller.site = Site[index_path.row]
    end
  end
end
