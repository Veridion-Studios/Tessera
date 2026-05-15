class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere

  # DISABLED: Support mailbox routing
  # routing /support|help/i => :support
end
