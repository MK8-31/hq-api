Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  mount_devise_token_auth_for 'User', at: 'api/v1/auth', controllers: {
    # カスタマイズするコントコーラーをここに記述
    sessions: 'api/v1/auth/sessions'
  }

  devise_scope :user do
    post 'api/v1/auth/test_login', to: 'api/v1/auth/sessions#test_login'
  end

  namespace :api do
    namespace :v1 do
      resources :tasks
      get :health_check, to: 'health_check#index'
      resources :task_records, only: %i[create destroy]
      get 'records/show', to: 'records#show'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
