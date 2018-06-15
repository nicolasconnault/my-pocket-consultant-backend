class DomainConstraint
  attr_accessor :domains

  def initialize(domain)
    @domains = [domain].flatten
  end

  def regular_expression domain
    Regexp.new "^#{domain.gsub('.','\.').gsub('*', '.*?')}$"
  end

  def matches?(request)
    @domains.each do |d|
      regexp = regular_expression d
      if regexp.match request.host
        return true
      end
    end

    false
  end
end
