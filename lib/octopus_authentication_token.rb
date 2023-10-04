require "graphql/client"
require "graphql/client/http"


class OctopusAuthenticationToken
  HTTP = GraphQL::Client::HTTP.new("https://api.oejp-kraken.energy/v1/graphql/")

  Schema = GraphQL::CLient.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  LoginQuery = OctopusAuthenticationToken::Client.parse <<~'GRAPHQL'
  mutation Login($input: ObtainJSONWebTokenInput!) {
    obtainKrakenToken(input: $input) {
      token
      refreshToken
    }
  }
  GRAPHQL

  def generate_token
    result = Client.query(LoginQuery, variables:{ 
      input: { 
          email: ENV['OCTOPUS_EMAIL'],
          password: ENV['OCTOPUS_PASSWORD']
      }
    })
    result.original_hash.dig("data", "obtainKrakenToken", "token")
  end
end 



puts GetOctopusAuthenticationToken
