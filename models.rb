require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    has_many :posts
    has_many :likes
    
    has_many :relationships
    has_many :followings, through: :relationships, source: :follow
    has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'follow_id'
    has_many :followers, through: :reverse_of_relationships, source: :user
    
    def follow(other_user)
        unless self == other_user
            self.relationships.create(user_id: self["id"], follow_id: other_user["id"])
        end
    end
    
    def unfollow(other_user)
        relationships = self.relationships.find_by(follow_id: other_user["id"])
        relationships.destroy if relationships
    end
    
    def following?(other_user)
        self.followings.include?(other_user)
    end
end

class Post < ActiveRecord::Base
    belongs_to :user
    has_many :likes
end

class Like < ActiveRecord::Base
    belongs_to :post
    belongs_to :user
end

class Relationship < ActiveRecord::Base
    belongs_to :user
    belongs_to :follow, class_name: 'User'
    
    validates :user_id, presence: true
    validates :follow_id, presence: true
end