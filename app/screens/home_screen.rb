class HomeScreen < UIViewController
  extend IB

  outlet :table, UITableView
  outlet :search_bar, UISearchBar
  outlet :forum_cell, HomeScreenForumCell

  FIXTURES = [
    {
      url: "http://l.discourse",
      title: "Local discourse"
    },
    {
      url: "https://discuss.howtogeek.com",
      title: "How-To Geek"
    },
    {
      url: "https://meta.discourse.org/",
      title: "Discourse Meta"
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
    cell = table_view.dequeueReusableCellWithIdentifier("HomeScreenForumCell", forIndexPath: index_path)
    cell.textLabel.text = FIXTURES[index_path.row][:title]
    cell.detailTextLabel.text = FIXTURES[index_path.row][:url]
    label = UILabel.alloc.initWithFrame(CGRectMake(10,10,10,10))
    label.text = "10"

    cell.accessoryView = label
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
