class ApplicationMailbox < ActionMailbox::Base
  routing(/support@|help@/i => :support)
end