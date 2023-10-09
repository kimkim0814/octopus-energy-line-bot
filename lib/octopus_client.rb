require "graphql/client"
require "graphql/client/http"

module OctopusClient    
  HTTP = GraphQL::Client::HTTP.new("https://api.oejp-kraken.energy/v1/graphql/") do
    def headers(context)
      { "Authorization" => "#{OctopusAuthenticationToken.new.generate_token}" }
    end
  end

  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
