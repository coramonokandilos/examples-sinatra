require "sinatra"
require "sinatra/cookies"
require "./environment"

helpers do
  def time_with_zone(time, zone_label)
    zone = TZInfo::Timezone.get(zone_label)
    offset = zone.period_for_utc(time).utc_offset

    time + offset
  end

  def format_time(time)
    time.strftime("%B %d, %Y at %l:%M%p")
  end

  def format_time_with_zone(time, zone_label)
    format_time(time_with_zone(time, zone_label))
  end
  def current_user
    # Return nil if no user is logged in
    return nil unless session.key?(:user_id)

    # If @current_user is undefined, define it by
    # fetching it from the database.
    @current_user ||= User.get(session[:user_id])
  end

  def user_signed_in?
    # A user is signed in if the current_user method
    # returns something other than nil
    !current_user.nil?
  end

  def sign_in!(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out!
    @current_user = nil
    session.delete(:user_id)
  end
end

set(:sessions, true)
set(:session_secret, ENV["SESSION_SECRET"])

post ("/photos/*/comments") do |photo_id|
  photo = Photo.get(photo_id)
  comment = Comment.new
  comment.body = params[:comment_body]
  comment.created_at=DateTime.now
  photo.comments.push(comment)
  photo.save
  redirect("/photos/#{photo_id}")
end

get("/") do
  photos = Photo.all(:order => [ :likes.desc, :created_at.desc ])
  erb(:index, :locals => { :photos => photos })
end

post("/photoLike/*") do |id|
  photo = Photo.get(id)
  photo.addLike()
  photo.save
  redirect("/")
end

get("/photos/new") do
  photo = Photo.new
  erb(:photos_new, :locals => { :photo => photo })
end

get("/photos/*") do |photo_id|
  photo = Photo.get(photo_id)
  erb(:photos_show, :locals => { :photo => photo })
end


post("/photos") do
  # set the user property in photo to the current user
  # there's a method called current_user in the example
  # app that will return the currently signed in user
  # if there is one.  Whenever a user uploads a photo,
  # you want to associate the photo with the current user.
  # Try out a few ideas for how to achieve this and flag
  # someone down if it's taking longer than 15 minutes or so.
  # puts params
  # puts 1
  # photo_unsaved = params[:photo]
  # photo_unsaved.user = current_user
  
  # photo = Photo.create(photo_unsaved)
  # photo.errors.each do |e|
  #   puts e
  # end
  photo = current_user.photos.create(params[:photo])
  
  puts 2
  if photo.saved?
    puts 3
    redirect("/")
  else
    puts 4
    erb(:photos_new, :locals => { :photo => photo })
  end
  puts 5
 def current_user
    # Return nil if no user is logged in
    return nil unless session.key?(:user_id)

    # If @current_user is undefined, define it by
    # fetching it from the database.
    @current_user ||= User.get(session[:user_id])
  end
  def user_signed_in?
    # A user is signed in if the current_user method
    # returns something other than nil
    !current_user.nil?
  end
  def sign_in!(user)
    session[:user_id] = user.id
    @current_user = user
  end
  def sign_out!
    @current_user = nil
    session.delete(:user_id)
  end
end
 
set(:sessions, true)
set(:session_secret, ENV["SESSION_SECRET"])

get("/") do
  users = User.all
  erb(:index, :locals => { :users => users })
end

get("/users/new") do
  user = User.new
  erb(:users_new, :locals => { :user => user })
end

post("/users") do
  user = User.create(params[:user])

  if user.saved?
    sign_in!(user)

    redirect("/")
  else
    erb(:users_new, :locals => { :user => user })
  end
end

get("/sessions/new") do
  user = User.new
  erb(:sessions_new, :locals => { :user => user })
end

post("/sessions") do
  user = User.find_by_username(params[:username])

  if user && user.valid_password?(params[:password])
    sign_in!(user)
    redirect("/")
  else
    erb(:sessions_new, :locals => { :user => user })
  end
end

get("/sessions/sign_out") do
  sign_out!
  redirect("/")
end


