class Notification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :sender, polymorphic: true


  enum category: {Friendship: 0, Duel: 1, Club: 2, Rival: 3, Account: 4, App: 5,  Message: 6, Callups: 7, Referee: 8, Challenge: 9}
  enum action: { Friend: 0, Callup: 1, Accepted: 2, Denied: 3, Suspended: 4, Solicitude: 5, Sanction: 6, Blocked: 7, Lesion: 8, Follower: 9, Invitation: 10, Challenges: 11}

  def category_name
    case category.to_sym
    when :Friendship
      "Alianzas"
    when :Duel
      "Duelos"
    when :Club
      "Equipos"
    when :Rival
      "Rival"
    when :Account
      "Tu cuenta"
    when :App
      "Entornes"
    when :Message
      "Mensaje"
    when :Callups
      "Convocatoria"
    when :Referee
      "Arbitraje"
    when :Challenge
      "Desafio"
    else
      ""
    end
  end

  def action_name
    case action.to_sym
    when :Friend
      "Amistad"
    when :Callup
      "Convocatoria"
    when :Accepted
      "Aceptado"
    when :Denied
      "Denegado"
    when :Suspended
      "Suspendido"
    when :Solicitude
      "Solicitud"
    when :Sanction
      "Sancion"
    when :Blocked
      "Bloqueo"
    when :Lesion
      "Lesion"
    when :Follower
      "Fan"
    when :Invitation
      "Invitacion"
    when :Challenges
      "Desafios"
    else
      ""
    end
  end

  def time_remaining
    time_remaining = (self.created_at - DateTime.now).to_i.abs

    if time_remaining >= 1.year
      years = (time_remaining / 1.year).to_i
      years > 1 ? "#{years}y" : "#{years}y"
    elsif time_remaining >= 1.month
      months = (time_remaining / 1.month).to_i
      months > 1 ? "#{months}m" : "#{months}m"
    elsif time_remaining >= 1.week
      weeks = (time_remaining / 1.week).to_i
      weeks > 1 ? "#{weeks}w" : "#{weeks}w"
    elsif time_remaining >= 1.day
      days = (time_remaining / 1.day).to_i
      days > 1 ? "#{days}d" : "#{days}d"
    elsif time_remaining >= 1.hour
      hours = (time_remaining / 1.hour).to_i
      hours > 1 ? "#{hours}h" : "#{hours}h"
    elsif time_remaining >= 1.minute
      minutes = (time_remaining / 1.minute).to_i
      minutes > 1 ? "#{minutes}min" : "#{minutes}min"
    else
      seconds = time_remaining
      seconds > 1 ? "#{seconds}s" : "#{seconds}s"
    end
  end


end
