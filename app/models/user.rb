require 'digest/sha1'

class User < Ohm::Model
  class WrongUsername < ArgumentError; end
  class WrongPassword < ArgumentError; end

  extend Spawn

  attribute :username
  attribute :password
  attribute :salt
  set :wins, Post
  set :losses, Post

  index :username

  def validate
    assert_present :username
    assert_present :password
    assert_unique :username
  end

  def self.authenticate(username, password)
    raise WrongUsername unless user = find(:username => username).first
    raise WrongPassword unless user.password == encrypt(password, user.salt)
    user
  end

  def password=(value)
    write_local(:salt, encrypt(Time.now.to_s, ""))

    value = value.empty? ? nil : encrypt(value, salt)

    write_local(:password, value)
  end

  def to_s
    username.to_s
  end

  def to_param
    username
  end

  def posts_authored
    Post.find(:author => id)
  end

  def votes_net
    posts_authored.inject(0) { |t, p| t + p.votes.to_i } 
 end

  def vote(post,direction)
    if voted?(post) != 0
      if direction == "w"
        if voted?(post) == -1
          post.incr(:votes)
          post.incr(:votes)
          losses.delete(post.id)
          wins.add(post)
        else
          post.decr(:votes)
          wins.delete(post.id)
        end
      elsif direction == "l"
        if voted?(post) == 1
          post.decr(:votes)
          post.decr(:votes)
          wins.delete(post.id)
          losses.add(post)
        else
          post.incr(:votes)
          losses.delete(post.id)
        end
      end
    else
      if direction == "w"
        post.incr(:votes)
        wins.add(post)
      elsif direction == "l"
        post.decr(:votes)
        losses.add(post)
      else
        post.incr(:votes)
        wins.add(post)
      end
    end
  end

  def voted?(post)
    if wins.include?(post.id)
      1
    elsif losses.include?(post.id)
      -1
    else
      0
    end
  end

private

  def self.encrypt(string, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{string}--")
  end

  def encrypt(*attrs)
    self.class.encrypt(*attrs)
  end
end

User.spawner do |user|
  user.username = Faker::Internet.user_name.tr(".", "")
  user.password = "monkey"
end
