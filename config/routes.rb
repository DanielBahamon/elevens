Rails.application.routes.draw do

  authenticated :user do
    root to: 'pages#console', as: :authenticated_root
  end

  unauthenticated do
    root to: 'pages#radar', as: :unauthenticated_root
  end

  resources :fields

  resources :users, only: [:show] do
    resources :goals, only: [:new, :create]
    resources :calendars
    member do
      post '/verify_phone_number' => 'users#verify_phone_number'
      patch 'update_phone_number' => 'users#update_phone_number'
      put 'follow' => 'users#follow'
      put 'unfollow' => 'users#unfollow'
      get 'clubs'
      get 'calledup'
      get 'view'
      get 'referee'
      get 'preview'
    end
  end
  resources :referees do
    member do
      get 'feed'
    end
  end
  resource :relationships, only: [:create, :destroy]
  resources :clubs, except: [:edit] do
    resources :invitations, only: [:new, :create]
    resources :calendars
    member do
      get 'edit'
      get 'duels'
      get 'members'
      get 'location'
      get 'scouting'
      get 'requests'
      get 'dashboard'
    end

    get 'join', on: :member
    get 'jointrue', on: :member
    post 'mark_all_as_read'
    post 'sendjoin/:user_id', to: 'clubs#sendjoin', as: 'sendjoin'
    post 'selfjoin/:user_id', to: 'clubs#selfjoin', as: 'selfjoin'

    resources :club_photos, only: [:create, :destroy]
    resources :memberships, only: [:create, :destroy, :edit, :update, :approve, :decline, :show] do 
      
      member do 
        post 'approve'
        get 'approve' 
        post 'decline' 
        get 'decline' 
      end
    end
    
    resources :duels do
      post :send_invitation, on: :member
      post 'join', on: :member
      get 'referee_access', on: :member
      get 'joinlines', on: :member
      resources :reservations, except: [:index, :new, :create]
      resources :invitations
      resources :duel_photos, only: [:create, :destroy]
      resources :rivals do
        post 'challenge', on: :collection
      end
      resources :reservations do 
        get 'reply'
      end
      resources :lines, only: [:create, :destroy, :edit, :update, :invoke, :ejected, :show] do 
        get 'join', on: :member
        get 'joinlines', on: :member
        member do 
          post '/invoke' => "lines#invoke"
          post '/ejected' => "lines#ejected"
        end
      end
      member do
        get 'front'
        get 'budget'
        get 'referee'
        get 'location'
        get 'panel'
        get 'members'
        get 'formation'
        get 'assignment'
        get 'control'
      end
    end
  end

  devise_for :users,
              path: '',
              path_names: {
                sign_in: 'login', 
                sign_out: 'logout', 
                edit: 'users/:id/edit',
                sign_up: 'registration' 
              }, 
              controllers: {
                omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations'
              }

  resources :notifications do
    member do
      patch :mark_as_read
    end
    
    collection do
      patch :mark_all_as_read
    end
  end



  get 'live' => 'pages#live'
  get 'radar' => 'pages#radar'
  get 'search' => 'pages#search'
  get 'battle' => 'pages#battle'
  get 'explore' => 'pages#explore'
  get 'console' => 'pages#console'
  get 'players' => 'pages#players'
  get 'notifications' => 'pages#notifications'
  get 'preload_tasks', to: 'pages#preload_tasks'
  get 'clubname_validator/:slug', to: 'clubs#clubname_validator'
  get 'username_validator/:slug', to: 'users#username_validator'
  get 'mentions', to: 'users#mentions'
  get 'calendar', to: 'calendars#host'  # Esta ruta apuntará al método 'user' del controlador 'CalendarsController'

  post '/create_auto_tasks', to: 'tasks#create_auto_tasks', as: :create_auto_tasks

  resources :tasks, only: [:index, :create, :edit, :update, :destroy]
  # post 'clubs/:club_id/create_approved_membership/:user_id', to: 'clubs#create_approved_membership', as: :create_approved_membership


end
 