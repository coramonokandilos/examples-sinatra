class User
  include DataMapper::Resource
  property :id,       Serial
  property :username, String,     :required => true, :unique => true
  property :password, BCryptHash, :required => true
  
  has n, :photos
    
  def self.find_by_username(username)
    User.first(:username => username)
  end
end