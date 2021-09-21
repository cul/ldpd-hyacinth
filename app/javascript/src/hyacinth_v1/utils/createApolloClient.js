import { ApolloClient } from 'apollo-client';
import { InMemoryCache, IntrospectionFragmentMatcher } from 'apollo-cache-inmemory';
import { HttpLink } from 'apollo-link-http';
import { onError } from 'apollo-link-error';
import { ApolloLink } from 'apollo-link';

// Helper method to create our Apollo instance. This method requires that the fragment types
// are passed in so that the instance can be configured properly. We migrated from apollo-boost
// to apollo-client to be able to configure our instance to our needs.
//
// Some things to know about our Apollo instance:
//   CACHING: We use an InMemoryCache and configure it to cache with the `network-only` policy. This
//            configuration fetches fresh data with every request and will no display stale results.
//            We use the network-only fetch policy instead of the `no-cache` policy because updating
//            results via fetchMore doesn't work when using a `no-cache` policy.
//            More information: https://github.com/apollographql/apollo-client/issues/5239
//
//   FRAGMENTS: In order for queries with fragments (see: Digital object queries) to work, we need
//              to provide our apollo instance with more information about the possible fragment
//              types. This function takes that information and creates the appropriate
//              fragment matcher that is then passed to our cache. With this set up we
//              are able to make fragment queries.

function createApolloClient(introspectionQueryResultData) {
  const fragmentMatcher = new IntrospectionFragmentMatcher({
    introspectionQueryResultData,
  });

  return new ApolloClient({
    link: ApolloLink.from([
      onError(({ graphQLErrors, networkError }) => {
        if (graphQLErrors) {
          graphQLErrors.forEach(({ message, locations, path }) => console.log(
            `[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`,
          ));
        }
        if (networkError) console.log(`[Network error]: ${networkError}`);
      }),
      new HttpLink({
        uri: '/graphql',
        credentials: 'same-origin',
      }),
    ]),
    cache: new InMemoryCache({ fragmentMatcher }),
    defaultOptions: {
      watchQuery: {
        errorPolicy: 'none',
        fetchPolicy: 'network-only',
      },
      query: {
        errorPolicy: 'none',
        fetchPolicy: 'network-only',
      },
      mutation: {
        errorPolicy: 'none',
      },
    },
  });
}

export default createApolloClient;
