class Site < CDQManagedObject
  def unreadTotal
    return unless unreadPM && unread
    unreadPM + unread
  end

  def self.search(term)
    return unless term =~ /^((https?):\/\/)?(\S+)$/

    protocol = $2
    domain = $3

    return nil if protocol && !["http", "https"].include?(protocol)

    if !protocol
      return search("http://#{domain}") || search("https://#{domain}")
    end

    lookup = "#{protocol}://#{domain}"
    puts "Looking up #{lookup}"

    mutex = Mutex.new
    done = false
    header = nil

    session = Net.build(lookup){}
    session.get("/") do |r|
      begin
        if r.body =~ /<head>(.*)<\/head>/mi
          mutex.synchronize{header = $1}
        end
        puts "I AM DONE"
        mutex.synchronize{done=true}
      rescue
      end
    end

    while !mutex.synchronize{done}
      sleep 0.01
    end

    puts header
    puts "DONE"
  rescue RuntimeError
    nil
  end
end
