class Main
  get "/" do
    @date = params[:date] ? Date.parse(params[:date]) : Date.today

    @just_added = recent(Post.by_date(Date.today))

    # Grab today's posts.
    @today = top(Post.by_date(@date))

    # Grab yesterday's posts.
    @yesterday = top(Post.by_date(@date - 1))

    today?

    haml :"home"
  end

  def today?
    params[:date] ? Date.parse(params[:date]) == Date.today : 0
  end
end
