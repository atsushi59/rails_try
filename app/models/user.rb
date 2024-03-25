class User < ApplicationRecord
    authenticates_with_sorcery!

    validates :user_name, presence: true, length: { maximum: 16 }
    validates :email, presence: true, uniqueness: true, format: { with: /\A\S+@\S+\.\S+\z/, message: "is not valid" }
    validates :name, presence: true, length: { maximum: 8 }, uniqueness: true
    validates :avatar, format: { with: /\.(png|jpg|jpeg)\z/i, message: "must be a valid image format" }
    validates :password, length: { minimum: 8 }
    validates :password_confirmation, presence: true, on: :create
    validate :password_complexity


    private

    def password_complexity
        return if password.blank? || password =~ /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*()_+}{"':;?\/>.<,])[A-Za-z\d!@#\$%^&*()_+}{"':;?\/>.<,]{8,}\z/
        
        errors.add :password, "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"
      end
      
      


end


