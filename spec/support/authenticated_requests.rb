module AuthenticatedRequests
  # Generates custom http request methods that end in `_with_auth`. These methods
  # add authentication to each request.
  [:get, :post, :patch, :delete].each do |http_method|
    define_method "#{http_method}_with_auth" do |path, **args|
      args[:headers] = args.fetch(:headers, {}).merge('Authorization' => 'Token firsttestkey')

      send(http_method, path, **args)
    end
  end
end
