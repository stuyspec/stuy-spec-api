class Resolvers::CreateUser < Resolvers::MutationFunction

  argument :first_name, !types.String
  argument :last_name, !types.String
  argument :email, !types.String
  argument :password, !types.String
  argument :password_confirmation, !types.String

  type Types::UserType

  def call(_obj, args, ctx)    
    if !validate_admin(ctx)
      return GraphQL::ExecutionError.new("Invalid user token. Please log in")
    end
    emailTaker = User.find_by(email: args["email"])
    if !emailTaker.nil?
      return GraphQL::ExecutionError.new(
        "Email taken by %s %s." % [emailTaker.first_name, emailTaker.last_name]
      )
    end
    @new_user = User.new(
      first_name: args[:first_name],
      last_name: args[:last_name],
      email: args[:email],
      password: args[:password],
      password_confirmation: args[:password_confirmation],
      created_at: Time.now
    )
    generate_new_header(ctx) if @new_user.save
    return @new_user
  end
  
end
