class APILog < ApplicationRecord
  belongs_to :user
  belongs_to :catalog, optional: true
end
