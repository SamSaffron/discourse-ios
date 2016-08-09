class HomeScreenViewModel
  attr_reader :resolved_sites

  def initialize
    @resolved_sites = []
  end

  def sites
    Site.all
  end

  def search_board(board, &block)
    return unless board =~ /^((https?):\/\/)?(\S+)$/

    protocol = $2
    domain = $3

    if protocol && !["http", "https"].include?(protocol)
      return nil
    end

    if !protocol
      return search_board("http://#{domain}", &block) || search_board("https://#{domain}", &block)
    end

    lookup = "#{protocol}://#{domain}".downcase
    done = false
    header = nil

    manager = AFHTTPSessionManager.manager
    manager.responseSerializer = AFHTTPResponseSerializer.serializer

    success_block = lambda { |task, response|
      match = response.to_s.match(/<title>(.*)<\/title>/)

      if match
        name = match.captures.first
        site = Site.new(name, lookup)
        @resolved_sites = [site]
      else
        @resolved_sites = []
      end

      block.call(@resolved_sites)
    }

    failure_block = lambda { |task, error| p error.localizedDescription }

    manager.GET(lookup, parameters: {}, success:success_block, failure:failure_block)
  end
end
