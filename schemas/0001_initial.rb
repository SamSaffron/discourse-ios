
schema "001 initial" do

    entity "Site" do

      string    :name,        optional: false
      string    :url,         optional: false
      string    :longDescription
      datetime  :lastChecked
      integer32 :unread
      integer32 :unreadPM
      string    :authToken
      string    :username
      string    :logoUrl
      binary    :logo

    end
end
