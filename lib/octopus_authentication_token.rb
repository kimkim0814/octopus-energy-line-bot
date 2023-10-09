require "graphql/client"
require "graphql/client/http"

class OctopusAuthenticationToken
  HTTP = GraphQL::Client::HTTP.new("https://api.oejp-kraken.energy/v1/graphql/")
  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  LOGIN_QUERY = self::Client.parse <<~GRAPHQL
    mutation($input: ObtainJSONWebTokenInput!) {
      obtainKrakenToken(input: $input) {
        token
        refreshToken
      }
    }
  GRAPHQL

  def generate_token
    result = Client.query(LOGIN_QUERY, variables: {
      input: {
        email: ENV["OCTOPUS_EMAIL"],
        password: ENV["OCTOPUS_PASSWORD"],
      },
    })
    result.original_hash.dig("data", "obtainKrakenToken", "token")
  end
end
