class Comment < Ohm::Model

  attribute :title
  attribute :text
  attribute :author
  attribute :next

  attribute :datetime

  def validate
    assert_length(:title,0..50)
    assert_present(:text)
    assert_present(:author)
  end

  def create
    self.datetime ||= Time.now.strftime("%Y-%m-%d %H:%M:%S")
    super
  end

  def display_comment
    partial(:"posts/comment", :title => title, :author => author, :text => text)
    :next.display_comment
  end

  def add(comment)
    if :comment
      :comment.add(comment)
    else
      set(:comment => @comment)
    end
  end

protected

  def assert_length(att, length)
    assert length === send(att).size, [att, :too_long]
  end
end
