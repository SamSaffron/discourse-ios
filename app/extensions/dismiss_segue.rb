class DismissSegue < UIStoryboardSegue
  def perform
    source_view_controller = self.sourceViewController
    source_view_controller.presentingViewController.dismissViewControllerAnimated(true, completion:nil)
  end
end
