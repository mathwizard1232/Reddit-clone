class Main
  get "/users/:username" do
    @user = User.find(:username => params[:username]).first
    @posts_authored = top(@user.posts_authored)
    @posts_liked = top(@user.wins.except(:author => @user.id))
    @posts_disliked = top(@user.losses)

    haml :"users/username"
  end
end
