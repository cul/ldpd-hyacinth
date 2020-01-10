import React from 'react';
import PropTypes from 'prop-types';
import { Route, Switch } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../ui/GraphQLErrors';
import { getMetadataDigitalObjectQuery } from '../../../graphql/digitalObjects';
import PageNotFound from '../../layout/PageNotFound';
import MetadataShow from './MetadataShow';
import MetadataEdit from './MetadataEdit';
import DigitalObjectProtectedRoute from '../../DigitalObjectProtectedRoute';

function Metadata(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getMetadataDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  return (
    <Switch>
      <Route
        exact
        path="/digital_objects/:id/metadata"
        render={() => <MetadataShow digitalObject={digitalObject} />}
      />

      <DigitalObjectProtectedRoute
        exact
        path="/digital_objects/:id/metadata/edit"
        render={() => <MetadataEdit digitalObject={digitalObject} />}
        requiredAbility={{
          action: 'read_objects',
          primaryProject: digitalObject.primaryProject,
          otherProjects: digitalObject.otherProjects,
        }}
      />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default Metadata;

Metadata.propTypes = {
  id: PropTypes.string.isRequired,
};
