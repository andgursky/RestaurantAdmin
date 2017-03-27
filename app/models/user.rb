class User < ApplicationRecord
  has_many :reserves, dependent: :destroy
end
