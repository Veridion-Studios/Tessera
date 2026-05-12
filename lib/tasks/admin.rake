namespace :admin do
  desc "Grant admin role to a user by email: rails admin:grant[user@example.com]"
  task :grant, [:email] => :environment do |_, args|
    email = args[:email]
    abort "Usage: rails admin:grant[user@example.com]" unless email.present?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    user.add_role!("admin")
    puts "✓ Admin role granted to #{user.email}"
  end

  desc "Revoke admin role: rails admin:revoke[user@example.com]"
  task :revoke, [:email] => :environment do |_, args|
    email = args[:email]
    user  = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    role = Role.find_by(name: "admin")
    user.user_roles.find_by(role: role)&.destroy
    puts "✓ Admin role revoked from #{user.email}"
  end

  desc "List all admins"
  task list: :environment do
    admins = User.joins(:roles).where(roles: { name: "admin" })
    if admins.any?
      admins.each { |u| puts "  #{u.email}" }
    else
      puts "No admins found."
    end
  end
end