class Xhr
  def self.build_message body, type = :success, heading = "Success"
    {type: type, body: body, heading: heading}
  end
end
