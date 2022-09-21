module AuthorizationHelpers
  def login(user)
    post '/api/v1/auth/sign_in',
         params: {
           email: user.email,
           password: user.password,
         },
         as: :json

    # STDOUT.puts(user.email)
    # STDOUT.puts(user.password)
    # STDOUT.puts("response.headers\n\n")
    # STDOUT.puts(response.body)
    # STDOUT.puts(response.headers)
    return response.headers.slice('client', 'access-token', 'uid')
  end
end
