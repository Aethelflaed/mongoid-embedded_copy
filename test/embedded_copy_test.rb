require 'test_helper'

class EmbeddedCopyTest < BaseTest
  test 'should raise if given class is not a Mongoid::Document' do
    assert_raises(ArgumentError) do
      Mongoid::EmbeddedCopy.for(BaseTest, in: User)
    end
  end

  test 'should raise if no :in argument is given' do
    assert_raises(ArgumentError) do
      Mongoid::EmbeddedCopy.for(User)
    end
  end

  test 'should access embedded copy' do
    user = User.create({firstname: 'Geoffroy', lastname: 'Planquart'})
    post = Post.create({title: 'Hello', content: 'Hello World', user: user, u: user})
    
    assert_equal User::CopyForPost, post.u.class
    assert_equal user, post.u.load_original
    assert_operator user, :==, post.u
    assert_operator post.u, :==, user
    assert post.u.eql?(user)
  end

  test 'should embeds copy of document embedding a copy of self' do
    class ::User
      embeds_copy :last_post, class_name: 'Post', skip: :u
    end

    user = User.create({firstname: 'Geoffroy', lastname: 'Planquart'})
    post = Post.create({title: 'Hello', content: 'Hello World', user: user, u: user})
    user.set(last_post: post)

    assert_operator post, :==, user.last_post
  end

  test 'load_original should return new value if copy is changed' do
    user1 = User.create({firstname: 'Geoffroy', lastname: 'Planquart'})
    user2 = User.create({firstname: 'John', lastname: 'Doe'})

    post = Post.create({title: 'Hello', content: 'Hello World', user: user1, u: user1})
    assert_equal user1, post.u.load_original
    post.set(u: user2)
    assert_equal user2, post.u.load_original
  end

  test 'should update original' do
    class ::User
      embeds_copy :first_post, class_name: 'Post', skip: :u, update_original: true, embedded_class: 'Copy'
    end

    post = Post.create({title: 'Hello', content: 'Hello World'})
    user = User.create({firstname: 'Geoffroy', lastname: 'Planquart', first_post: post})
    user.first_post.set(title: 'World')

    assert_equal Post::Copy, user.first_post.class

    assert_equal 'World', post.reload.title
  end
end

