class AddChanges2ToDuels < ActiveRecord::Migration[6.1]
  def up
    change_column :duels, :club_id, :string
  end

  def down
    change_column :duels, :club_id, :integer

    # Si es necesario, puedes agregar un código adicional para restaurar los datos originales.
    # Por ejemplo, si tienes datos en formato de string que deseas convertir de nuevo a integer.
    # Esto dependerá de tu aplicación y los datos que tengas en la columna.
  end
end
