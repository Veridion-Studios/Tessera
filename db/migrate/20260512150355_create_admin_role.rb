class CreateAdminRole < ActiveRecord::Migration[8.1]
  def up
    Role.find_or_create_by!(name: "admin")
  end

  def down
    Role.find_by(name: "admin")&.destroy
  end
end