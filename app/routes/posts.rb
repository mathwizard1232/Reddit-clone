class Main
  get "/posts/new" do
    @post = Post.new
    haml :"posts/new"
  end

  get "/posts/:id" do
    @post = Post[params[:id]]
    @author = User[@post.author]
    @url = @post.location
    @id = params[:id]
    haml :"posts/id"
  end

  post "/posts" do
    accept_login_or_signup

    @post = Post.new(params[:post])
    @post.author = current_user.id if current_user

    if @post.valid?
      @post.create
      current_user.vote(@post,"w")
      session[:notice] = "Your link has been added"
      redirect "/"
    else
      haml :"posts/new"
    end
  end

  post "/posts/:id" do
    accept_login_or_signup

    @post = Post[params[:id]]
    @vote = params[:submit]

    current_user.vote(@post,@vote)
    
    redirect back
  end

  post "/posts/:id/addcomment" do
    accept_login_or_signup

    @post = Post[params[:id]]
    @post.addcomment(params,current_user.username)

    redirect back
  end

  module Helpers
    def link_to_post(post)
      capture_haml do
        haml_tag(:a, post, :href => "/posts/#{post.id}", :title => post)
      end
    end

    def friendly_date(date)
      today = Date.today

      case date
      when today - 1
        "Yesterday"
      when today
        "Today"
      when today + 1
        "Tomorrow"
      else
        dow = DAYS[date.wday]

        if date.year == today.year
          if date.month == today.month
            "#{dow} #{date.strftime "%d"}"
          else
            "#{dow} #{date.strftime "%d/%m"}"
          end
        else
          "#{dow} #{date.strftime "%d/%m/%y"}"
        end
      end
    end

    def list(title, posts, message = "Nothing interesting here.")
      partial(:"posts/list", :title => title, :posts => posts, :message => message)
    end

    def top(posts)
      posts.sort_by(:votes, :limit => 15, :order => "DESC")
    end

    def recent(posts)
      posts.sort_by(:datetime, :order => "ALPHA DESC", :limit => 15)
    end

    def vote_post(post)
      voted = current_user.voted?(post) if logged_in?
      capture_haml do
        haml_tag(:form, :action => "/posts/#{post.id}", :method => "post", :class => "vote") do
          haml_tag(:button, "w", :type => "submit", :name => "submit", :value => "w",  :class => voted==1 ? "voted" : "")
          haml_tag(:button, "l", :type => "submit", :name => "submit", :value => "l", :class => voted==-1 ? "voted" : "")
        end
      end
    end
  end

  include Helpers
end
