class Resolvers::CreateMedium < Resolvers::MutationFunction

  # arguments passed as "args"
  # TODO: make is_featured mandatory
  argument :title, !types.String
  argument :article_id, types.Int
  argument :user_id, !types.Int
  argument :is_featured do
    type types.Boolean
    description 'Whether the medium will be shown at the top of its article.'
  end
  argument :caption, types.String
  argument :media_type, !types.String
  argument :attachment_b64, as: :attachment do
    type !types.String
    description 'The base64 encoded version of the attachment to upload.'
  end

  # return type from the mutation
  type Types::MediumType

  # the mutation method
  # _obj - is parent object, which in this case is nil
  # args - are the arguments passed
  # _ctx - is the GraphQL context (which would be discussed later)
  def call(_obj, args, ctx)
    if !Authentication::editor_is_valid(ctx)
      return GraphQL::ExecutionError.new("Invalid user token. Please log in.")
    end

    ActiveRecord::Base.transaction do
      media_type = args["media_type"]
      if media_type != "illustration" && media_type != "photo"
        return GraphQL::ExecutionError.new(
          "#{media_type} is currently unsupported"
        )
      end

      if media_type == "illustration"
        roleTitle = "Illustrator"
      else      
        roleTitle = "Photographer"
      end
      role = Role.find_by(title: roleTitle)

      profile = Profile.find_or_create_by(
        role_id: role.id,
        user_id: args["user_id"]
      )

      @medium = Medium.new(
        title: args["title"],
        article_id: args["article_id"],
        profile_id: profile.id,
        is_featured: args["is_featured"] || false,
        caption: args["caption"],
        media_type: args["media_type"],
        attachment: args["attachment"],
      )
      Authentication::generate_new_header(ctx) if @medium.save!
    end
    return @medium
  end
end
