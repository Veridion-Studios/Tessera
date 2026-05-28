# frozen_string_literal: true

seed_password = ENV.fetch("SEED_PASSWORD", "Password123!")

developers = [
  {
    email: "alex.moriarty@example.com",
    username: "alexmoriarty",
    display_name: "Alex Moriarty",
    location: "Denver, CO",
    tagline: "Rails performance and product polish",
    bio: "Backend-focused developer specializing in fast Rails apps, clean APIs, and pragmatic UX.",
    availability: "open",
    skill_tags: ["Ruby on Rails", "PostgreSQL", "Redis", "Docker"],
    hourly_rate: 110,
    portfolio: [
      {
        title: "Ops Metrics Dashboard",
        github_repo_url: "https://github.com/tessera-demo/alex-ops-metrics",
        project_demo_url: "https://ops-metrics.example.com",
        tech_tags: ["Ruby on Rails", "PostgreSQL", "Redis"],
        description: "Operational analytics dashboard with role-based access and realtime updates.",
        status: "approved"
      },
      {
        title: "Shipment Tracker",
        github_repo_url: "https://github.com/tessera-demo/alex-shipment-tracker",
        project_demo_url: "https://shipment-tracker.example.com",
        tech_tags: ["Ruby on Rails", "JavaScript"],
        description: "Carrier-agnostic shipment tracking with alerts and CSV exports.",
        status: "approved"
      }
    ]
  },
  {
    email: "bri.chen@example.com",
    username: "brichen",
    display_name: "Bri Chen",
    location: "Austin, TX",
    tagline: "Product UX + full-stack delivery",
    bio: "Full-stack developer building clear, user-first interfaces and resilient APIs.",
    availability: "open",
    skill_tags: ["React", "TypeScript", "Ruby on Rails", "PostgreSQL"],
    hourly_rate: 125,
    portfolio: [
      {
        title: "Client Portal",
        github_repo_url: "https://github.com/tessera-demo/bri-client-portal",
        project_demo_url: "https://client-portal.example.com",
        tech_tags: ["React", "TypeScript", "Ruby on Rails"],
        description: "Secure portal with file delivery, signatures, and notifications.",
        status: "approved"
      },
      {
        title: "Invoice Builder",
        github_repo_url: "https://github.com/tessera-demo/bri-invoice-builder",
        project_demo_url: "https://invoice-builder.example.com",
        tech_tags: ["React", "PostgreSQL"],
        description: "Template-driven invoice generator with PDF exports and payment links.",
        status: "approved"
      }
    ]
  },
  {
    email: "devon.ramos@example.com",
    username: "devonr",
    display_name: "Devon Ramos",
    location: "Brooklyn, NY",
    tagline: "Data-heavy apps and integrations",
    bio: "Backend engineer focused on data pipelines, integrations, and fast search.",
    availability: "busy",
    skill_tags: ["Ruby on Rails", "PostgreSQL", "Node.js", "Docker"],
    hourly_rate: 140,
    portfolio: [
      {
        title: "Inventory Sync",
        github_repo_url: "https://github.com/tessera-demo/devon-inventory-sync",
        project_demo_url: "https://inventory-sync.example.com",
        tech_tags: ["Node.js", "PostgreSQL"],
        description: "Multi-channel inventory sync with conflict resolution and audits.",
        status: "approved"
      },
      {
        title: "Revenue Forecasting",
        github_repo_url: "https://github.com/tessera-demo/devon-forecasting",
        project_demo_url: "https://forecasting.example.com",
        tech_tags: ["Ruby on Rails", "PostgreSQL"],
        description: "Scenario-based revenue forecasts with historical trend analysis.",
        status: "approved"
      }
    ]
  },
  {
    email: "eli.kim@example.com",
    username: "elikim",
    display_name: "Eli Kim",
    location: "Seattle, WA",
    tagline: "API design and clean integrations",
    bio: "Developer focused on clean API contracts, OAuth flows, and integrations.",
    availability: "open",
    skill_tags: ["Ruby on Rails", "TypeScript", "Redis", "AWS"],
    hourly_rate: 130,
    portfolio: [
      {
        title: "Partner API Hub",
        github_repo_url: "https://github.com/tessera-demo/eli-partner-api",
        project_demo_url: "https://partner-api.example.com",
        tech_tags: ["Ruby on Rails", "Redis"],
        description: "Partner-facing API hub with webhook delivery and signing.",
        status: "approved"
      },
      {
        title: "Auth Console",
        github_repo_url: "https://github.com/tessera-demo/eli-auth-console",
        project_demo_url: "https://auth-console.example.com",
        tech_tags: ["TypeScript", "AWS"],
        description: "Admin console for managing OAuth clients and audit logs.",
        status: "approved"
      }
    ]
  },
  {
    email: "farah.singh@example.com",
    username: "farahsingh",
    display_name: "Farah Singh",
    location: "Chicago, IL",
    tagline: "Marketplace and payments workflows",
    bio: "Full-stack developer building marketplace flows, payouts, and subscriptions.",
    availability: "unavailable",
    skill_tags: ["Ruby on Rails", "PostgreSQL", "Stripe", "React"],
    hourly_rate: 150,
    portfolio: [
      {
        title: "Vendor Marketplace",
        github_repo_url: "https://github.com/tessera-demo/farah-marketplace",
        project_demo_url: "https://vendor-marketplace.example.com",
        tech_tags: ["Ruby on Rails", "PostgreSQL"],
        description: "Marketplace with onboarding, payouts, and dispute workflows.",
        status: "approved"
      },
      {
        title: "Subscription Studio",
        github_repo_url: "https://github.com/tessera-demo/farah-subscriptions",
        project_demo_url: "https://subscription-studio.example.com",
        tech_tags: ["React", "Ruby on Rails"],
        description: "Self-serve subscription management with invoices and usage tracking.",
        status: "approved"
      }
    ]
  }
]

developers.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])

  if user.new_record?
    user.initial_role = :developer
    user.password = seed_password
    user.username = attrs[:username]
    user.preferred_first_name = attrs[:display_name].split.first
    user.preferred_last_name = attrs[:display_name].split.last
    user.identity_status = "verified"
  else
    user.username ||= attrs[:username]
  end

  user.save! if user.changed?

  user.add_role!(:developer) unless user.developer?

  profile = user.developer_profile || user.build_developer_profile
  profile.assign_attributes(
    display_name: attrs[:display_name],
    location: attrs[:location],
    tagline: attrs[:tagline],
    bio: attrs[:bio],
    availability: attrs[:availability],
    skill_tags: attrs[:skill_tags],
    hourly_rate: attrs[:hourly_rate],
    verification_status: "approved",
    connect_onboarding_status: "active"
  )
  profile.save! if profile.changed?

  attrs[:portfolio].each do |portfolio|
    PortfolioSubmission.find_or_create_by!(
      user: user,
      github_repo_url: portfolio[:github_repo_url]
    ) do |submission|
      submission.title = portfolio[:title]
      submission.project_demo_url = portfolio[:project_demo_url]
      submission.tech_tags = portfolio[:tech_tags]
      submission.description = portfolio[:description]
      submission.status = portfolio[:status]
    end
  end
end
