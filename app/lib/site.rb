class Site
  attr_accessor :name
  attr_accessor :url
  attr_accessor :long_description
  attr_accessor :last_checked
  attr_accessor :unread
  attr_accessor :unread_pm
  attr_accessor :auth_token
  attr_accessor :username
  attr_accessor :logo_url
  attr_accessor :logo

  def initialize(name, url)
    @name = name
    @url = url
  end

  def unread_total
    return unless unread_pm && unread
    unread_pm + unread
  end

  def encodeWithCoder(encoder)
    encoder.encodeObject(self.name, forKey:"name")
    encoder.encodeObject(self.url, forKey:"url")
    encoder.encodeObject(self.long_description, forKey:"long_description")
    encoder.encodeObject(self.last_checked, forKey:"last_checked")
    encoder.encodeObject(self.unread, forKey:"unread")
    encoder.encodeObject(self.unread_pm, forKey:"unread_pm")
    encoder.encodeObject(self.auth_token, forKey:"auth_token")
    encoder.encodeObject(self.username, forKey:"username")
    encoder.encodeObject(self.logo_url, forKey:"logo_url")
    encoder.encodeObject(self.logo, forKey:"logo")
  end

  def initWithCoder(decoder)
    self.name = decoder.decodeObjectForKey("name")
    self.url = decoder.decodeObjectForKey("url")
    self.long_description = decoder.decodeObjectForKey("long_description")
    self.last_checked = decoder.decodeObjectForKey("last_checked")
    self.unread = decoder.decodeObjectForKey("unread")
    self.unread_pm = decoder.decodeObjectForKey("unread_pm")
    self.auth_token = decoder.decodeObjectForKey("auth_token")
    self.username = decoder.decodeObjectForKey("username")
    self.logo_url = decoder.decodeObjectForKey("logo_url")
    self.logo = decoder.decodeObjectForKey("logo")
    self
  end

  def save
    sites = Site.all.unshift(self)
    encoded_sites = NSKeyedArchiver.archivedDataWithRootObject(sites)
    defaults = NSUserDefaults.standardUserDefaults
    defaults.setObject(encoded_sites, forKey:"_sites_v1")
    defaults.synchronize
  end

  def self.all
    defaults = NSUserDefaults.standardUserDefaults
    NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("_sites_v1")) || []
  end
end
