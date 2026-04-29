class Game < ApplicationRecord
    has_many :categories, dependent: :destroy
end
