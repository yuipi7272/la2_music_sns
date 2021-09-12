require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    has_many :posts
    has_many :likes
end

class Post < ActiveRecord::Base
    belongs_to :user
    has_many :likes
end

class Like < ActiveRecord::Base
    belongs_to :post
    belongs_to :user
end