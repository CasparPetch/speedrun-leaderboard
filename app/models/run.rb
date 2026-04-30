class Run < ApplicationRecord
  belongs_to :user
  belongs_to :category

  
  enum :status, {
    submitted: 0,
    verified: 1,
    rejected: 2,
    deleted: 3,
    obsoleted: 4
  }

end
