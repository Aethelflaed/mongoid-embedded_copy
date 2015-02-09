# mongoid-embedded_copy

Create a mimic of a root document to use as a copy embedded in another document.

Please report any issue you may find.

If you'd like to contribute, but pull requests are welcome!

## Install

```ruby
gem 'mongoid-embedded_copy'
```

## How to use

```ruby
class User
  include Mongoid::Document
  include Mongoid::EmbeddedCopy

  field :firstname
  # [...]

  has_many :posts
  embeds_copy :last_post, class_name: 'Post'
end

# Then use it
user = User.create
post = Post.create(title: 'Hello World!', user: user)
user.last_post = post
```

## Why ?

The copy is embedded in the document, so it is much faster to access its values.

For example, you can easily search by users last post date: `User.where(:'last_post.created_at'.gt => Date.yesterday)`.

## Notes

* You are responsible for keeping the embedded copy up-to-date.
* Setters on the copy also update the original document if `update_original` option is given.
* The embedded copy has the same ID as the original document, so you can easily find the original, although there is `load_original` for this purpose.
* You can skip attributes with the `:skip` options to `embeds_copy`.
* The relation name is automatically skipped, e.g. `user.last_post` doesn't have an `user_id`.
* The class created for a `last_post` of class `Post` in a `User` is named `Post::CopyForUser`.
* A method named `acts_as_#{klass.to_s.underscore}` is defined in the copy and original class.
* You can use `:embedded_class` to specify another name for the copy class.

