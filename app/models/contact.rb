class Contact < ApplicationRecord
  belongs_to :user

  %W(first_name last_name).each do |name|
    validates name, presence: :true
    validates_format_of name, with: /\A[a-zA-Z\.'-_]*\z/#, multiline: true
  end

  validates :email, presence: :true, uniqueness: { case_sensitive: false }
  validates_format_of :email, with: /\A[^@\s]+@[^@\s]+\z/

  validates :phone_number, presence: :true, uniqueness: :true
  validates_format_of :phone_number, with: 
  /\A(?:(?:\(?(?:00|\+)([1-4]\d\d|[1-9]\d?)\)?)?[\-\.\ \\\/]?)?((?:\(?\d{1,}\)?[\-\.\ \\\/]?){0,})(?:[\-\.\ \\\/]?(?:#|ext\.?|extension|x)[\-\.\ \\\/]?(\d+))?\z/i

end
