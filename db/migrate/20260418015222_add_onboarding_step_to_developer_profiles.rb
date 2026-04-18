class AddOnboardingStepToDeveloperProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :developer_profiles, :onboarding_step, :integer, null: false, default: 1
  end
end