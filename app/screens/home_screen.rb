class HomeScreen < UIViewController
  extend IB

  outlet :table, UITableView
  outlet :search_bar, UISearchBar
  outlet :forum_cell, HomeScreenForumCell

  FIXTURES = [
    {
      url: "http://l.discourse",
      title: "Local discourse",
      unread: 7
    },
    {
      url: "https://discuss.howtogeek.com",
      title: "How-To Geek",
      unread: 2
    },
    {
      url: "https://meta.discourse.org/",
      title: "Discourse Meta",
      unread: nil
    }
  ]

  def viewDidLoad
    super
    self.title = "Discourse"
    self.view.backgroundColor = UIColor.discourse_red
  end

  def tableView(table_view, numberOfRowsInSection:section)
    FIXTURES.count
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    data = FIXTURES[index_path.row]
    cell = table_view.dequeueReusableCellWithIdentifier("HomeScreenForumCell", forIndexPath: index_path)
    cell.textLabel.text = data[:title]
    cell.detailTextLabel.text = data[:url]

    if data[:unread] && data[:unread] > 0
      label = UILabel.alloc.initWithFrame(CGRectMake(10,10,10,10))
      label.text = data[:unread] ? data[:unread].to_s : ""
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
      controller.forum = FIXTURES[index_path.row]
    end
  end
end
