class Comment
  include DataMapper::Resource
  property :id,        Serial
  property :body,      Text,       required: true
  property :created_at, DateTime,   required: true
  
  belongs_to :photo
end