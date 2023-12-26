class Goal < ApplicationRecord
  belongs_to :user
  belongs_to :duel
  belongs_to :club
  
  def allow_edit_goal?(user)
    # Lógica para verificar si el usuario tiene permiso para editar este gol
    # Por ejemplo, si el usuario es árbitro o el propietario del duelo asociado al gol
    duel.allow_edit_score?(user) # Puedes reutilizar la lógica definida en el modelo Duel
  end
end