class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Default new tables to UUID primary keys
  self.implicit_order_column = "created_at"
end