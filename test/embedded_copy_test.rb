require 'test_helper'

class EmbeddedCopyTest < BaseTest
  test 'should raise if given class is not a Mongoid::Document' do
    assert_raises(ArgumentError) do
      Mongoid::EmbeddedCopy.for(BaseTest)
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

  test 'should be able to ' do
    class << Object; def pryit; true; end; end
    class ::User
      embeds_copy :last_post, class_name: 'Post', skip: :u
    end

    user = User.create({firstname: 'Geoffroy', lastname: 'Planquart'})
    post = Post.create({title: 'Hello', content: 'Hello World', user: user, u: user})
    user.set(last_post: post)

    assert_operator post, :==, user.last_post
  end
end

