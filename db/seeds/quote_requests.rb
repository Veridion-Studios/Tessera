# frozen_string_literal: true

seed_password = ENV.fetch("SEED_PASSWORD", "Password123!")

customers = [
  {
    email: "stella@northwind.io",
    username: "stellaross",
    display_name: "Stella Ross",
    company_name: "Northwind Labs"
  },
  {
    email: "maria@primrose.co",
    username: "mariac",
    display_name: "Maria Cole",
    company_name: "Primrose"
  },
  {
    email: "jon@atlasworks.io",
    username: "jonatlas",
    display_name: "Jon Atlas",
    company_name: "Atlasworks"
  }
]

customers.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])

  if user.new_record?
    user.initial_role = :customer
    user.password = seed_password
    user.username = attrs[:username]
    user.preferred_first_name = attrs[:display_name].split.first
    user.preferred_last_name = attrs[:display_name].split.last
    user.identity_status = "verified"
  else
    user.username ||= attrs[:username]
  end

  user.save! if user.changed?
  user.add_role!(:customer) unless user.customer?

  profile = user.customer_profile || user.build_customer_profile
  profile.assign_attributes(
    display_name: attrs[:display_name],
    company_name: attrs[:company_name],
    identity_status: "verified"
  )
  profile.save! if profile.changed?
end

developer_emails = [
  "alex.moriarty@example.com",
  "bri.chen@example.com",
  "devon.ramos@example.com",
  "eli.kim@example.com"
]

developers = User.where(email: developer_emails).index_by(&:email)
customers_by_email = User.where(email: customers.map { |c| c[:email] }).index_by(&:email)

quotes = [
  {
    customer_email: "stella@northwind.io",
    developer_email: "alex.moriarty@example.com",
    title: "Ops visibility dashboard",
    description: "We need a lightweight ops dashboard that pulls from Postgres and shows daily KPIs, error rates, and queue backlog.",
    timeline: "6-8 weeks",
    budget_min: 15000,
    budget_max: 22000,
    engagement_type: "fixed",
    status: "submitted",
    tech_tags: ["Ruby on Rails", "PostgreSQL", "Redis"]
  },
  {
    customer_email: "maria@primrose.co",
    developer_email: "bri.chen@example.com",
    title: "Client portal refresh",
    description: "We want to redesign our client portal and add document uploads, status updates, and milestone approvals.",
    timeline: "8-10 weeks",
    budget_min: 24000,
    budget_max: 32000,
    engagement_type: "fixed",
    status: "negotiating",
    tech_tags: ["React", "Ruby on Rails"]
  },
  {
    customer_email: "jon@atlasworks.io",
    developer_email: "devon.ramos@example.com",
    title: "Inventory sync integrations",
    description: "Integrate Shopify + WooCommerce inventory sync with nightly reconciliation and alerts.",
    timeline: "4-6 weeks",
    budget_min: 12000,
    budget_max: 18000,
    engagement_type: "fixed",
    status: "accepted",
    tech_tags: ["PostgreSQL", "Node.js"]
  },
  {
    customer_email: "stella@northwind.io",
    developer_email: "eli.kim@example.com",
    title: "Partner API improvements",
    description: "Add OAuth client management, webhook retries, and usage analytics to our partner API.",
    timeline: "3-5 weeks",
    budget_min: 10000,
    budget_max: 16000,
    engagement_type: "retainer",
    status: "declined",
    tech_tags: ["Ruby on Rails", "Redis"]
  }
]

quotes.each do |attrs|
  customer = customers_by_email[attrs[:customer_email]]
  developer = developers[attrs[:developer_email]]
  next unless customer && developer

  quote = QuoteRequest.find_or_initialize_by(
    customer: customer,
    developer: developer,
    title: attrs[:title]
  )

  base_time = 10.days.ago
  quote.assign_attributes(
    description: attrs[:description],
    timeline: attrs[:timeline],
    budget_min: attrs[:budget_min],
    budget_max: attrs[:budget_max],
    engagement_type: attrs[:engagement_type],
    status: attrs[:status],
    tech_tags: attrs[:tech_tags],
    submitted_at: base_time,
    expires_at: base_time + 21.days
  )

  case attrs[:status]
  when "viewed"
    quote.viewed_at = base_time + 1.day
  when "negotiating"
    quote.viewed_at = base_time + 1.day
    quote.responded_at = base_time + 2.days
  when "accepted"
    quote.viewed_at = base_time + 1.day
    quote.responded_at = base_time + 3.days
    quote.accepted_at = base_time + 3.days
    quote.agreed_amount = attrs[:budget_max]
    quote.agreed_timeline = attrs[:timeline]
    quote.estimated_start_date = Date.current + 7.days
    quote.estimated_end_date = Date.current + 40.days
  when "declined"
    quote.viewed_at = base_time + 1.day
    quote.responded_at = base_time + 2.days
    quote.declined_at = base_time + 2.days
  when "withdrawn"
    quote.responded_at = base_time + 3.days
  end

  quote.save! if quote.changed?

  if quote.thread_messages.none?
    QuoteThreadMessage.create!(
      quote_request: quote,
      author: customer,
      kind: "message",
      body: "Hi! Happy to share more detail. Let me know what info you need to scope this."
    )

    if quote.status.in?(%w[negotiating accepted declined])
      QuoteThreadMessage.create!(
        quote_request: quote,
        author: developer,
        kind: "message",
        body: "Thanks! I can take this on. I have a couple scope clarifications before we finalize."
      )
    end

    if quote.status == "negotiating"
      QuoteThreadMessage.create!(
        quote_request: quote,
        author: developer,
        kind: "counter_proposal",
        body: "I can deliver this in 9 weeks with a phased rollout.",
        proposed_amount: attrs[:budget_max] - 2000,
        proposed_timeline: "9 weeks",
        proposed_start_date: Date.current + 10.days,
        proposed_end_date: Date.current + 70.days
      )
    end
  end

  next unless quote.milestones.none?

  if quote.status == "accepted"
    QuoteMilestone.create!(
      quote_request: quote,
      proposed_by: developer,
      title: "Discovery + integration plan",
      description: "Audit existing inventory flows and define integration plan.",
      amount: 5000,
      due_date: Date.current + 14.days,
      position: 1,
      status: "accepted"
    )

    QuoteMilestone.create!(
      quote_request: quote,
      proposed_by: developer,
      title: "Sync pipelines",
      description: "Build sync jobs, reconciliation logic, and monitoring hooks.",
      amount: 8000,
      due_date: Date.current + 35.days,
      position: 2,
      status: "proposed"
    )
  end
end
