class Main
  module Helpers
    def display_comment(title, text, author)
      partial(:"posts/comment", :title => title, :author => author, :text => text)
    end

  end
end
