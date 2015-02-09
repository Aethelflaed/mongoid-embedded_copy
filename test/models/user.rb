class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :firstname
  field :lastname

  has_many :posts
end

