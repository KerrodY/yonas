class AddExtraInfoToCompanyApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :company_applications, :extra_info, :text
    change_column_null :company_applications, :online_at_launch, true
  end
end
