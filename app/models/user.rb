class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.new_guest
    guest = self.create(:email => nil,
                        :username => nil,
                        :guest => true)
    guest.save(:validate => false)
    return guest
  end

end
