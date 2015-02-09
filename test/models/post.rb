class Post
  include Mongoid::Document
  include Mongoid::EmbeddedCopy

  field :title
  field :content

  embeds_copy :u, class_name: 'User'
  belongs_to :user
end

