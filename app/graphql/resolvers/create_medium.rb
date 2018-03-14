class Resolvers::CreateMedium < Resolvers::MutationFunction
  # arguments passed as "args"
  argument :title, !types.String
  argument :article_id, !types.Int
  argument :profile_id, !types.Int
  argument :caption, !types.String
  argument :media_type, !types.String
  argument :attachmentBase64, as: :attachment do
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
    validate_admin(ctx)
    @medium = Medium.new(
      title: args["title"],
      article_id: args["article_id"],
      profile_id: args["profile_id"],
      caption: args["caption"],
      media_type: args["media_type"],
    )
    generate_new_header(ctx) if @medium.save
    return @medium
  end
end
