 Timezone::Lookup.config(:google) do |c|
   c.api_key = Rails.application.credentials.google[:api_key]
 end
