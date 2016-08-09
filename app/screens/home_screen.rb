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
  end

  def view_model
    @view_model ||= HomeScreenViewModel.new
  end

  def searchBar(search_bar, textDidChange: text)
    if text =~ /.+\..+/
      view_model.search_board(text) do |site|
        self.table.reloadData
      end
    end
  end

  def searchBarTextDidBeginEditing(search_bar)
    self.search_bar.showsCancelButton = true
  end

  def searchBarCancelButtonClicked(search_bar)
    search_bar.text = ""
    self.search_bar.showsCancelButton = false
    self.search_bar.resignFirstResponder
    self.table.reloadData
  end

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(table_view, numberOfRowsInSection:section)
    case section
    when 0
      if self.search_bar.isFirstResponder
        return view_model.resolved_sites.count
      else
        0
      end
    when 1
      if self.search_bar.isFirstResponder
        return 0
      else
        return view_model.sites.count
      end
    end
  end

  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    table_view.deselectRowAtIndexPath(index_path, animated: true)

    if self.search_bar.isFirstResponder
      site = view_model.resolved_sites[index_path.row]
      site.save
      self.search_bar.resignFirstResponder
      self.table.reloadData
    else
      story_board = UIStoryboard.storyboardWithName("Discourse", bundle:nil)
      controller = story_board.instantiateViewControllerWithIdentifier("DiscourseScreen")
      controller.site = view_model.sites[index_path.row]
      self.navigationController.pushViewController(controller, animated: true)
    end
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    cell = table_view.dequeueReusableCellWithIdentifier("HomeScreenForumCell", forIndexPath: index_path)

    if self.search_bar.isFirstResponder
      site = view_model.resolved_sites[index_path.row]
    else
      site = view_model.sites[index_path.row]
    end

    if site.unread_total && site.unread_total > 0
      label = UILabel.alloc.initWithFrame(CGRectMake(10,10,10,10))
      label.text = site.unread_total.to_s
      label.sizeToFit
      cell.accessoryView = label
    end

    cell.textLabel.text = site.name
    cell.detailTextLabel.text = site.url
    cell
  end
end
