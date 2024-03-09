class ClubPhoto < ApplicationRecord
  belongs_to :club

  
  has_one_attached :image

  # has_attached_file :image, styles: {extralarge: "1000x1000>", large: "800x800>", medium: "600x600>", thumb: "350x350>" }, default_url: "https://s3.amazonaws.com/mockertest/assets/unnamed.jpg"
  # validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  
end
