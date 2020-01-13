import React from 'react';
import PropTypes from 'prop-types';
import { Route, Switch, useRouteMatch } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../ui/GraphQLErrors';
import PageNotFound from '../../layout/PageNotFound';
import RightsShow from './RightsShow';
import ItemRightsForm from './ItemRightsForm';
import DigitalObjectProtectedRoute from '../../DigitalObjectProtectedRoute';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';

function Rights(props) {
  const { id } = props;
  const { path } = useRouteMatch();

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getRightsDigitalObjectQuery, {
    variables: { id },
    onCompleted: (data) => {
      console.log('Rights component onCompleted with data');
      console.log(data);
    }
  });

  console.log('rights got:');
  console.log(digitalObjectData);

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  return (
    <Switch>
      <Route
        exact
        path={path}
        render={() => <RightsShow digitalObject={digitalObject} />}
      />
      <DigitalObjectProtectedRoute
        path={`${path}/edit`}
        render={() => {
          switch (digitalObject.digitalObjectType) {
            case 'item':
              return <ItemRightsForm digitalObject={digitalObject} />;
            default:
              return `Rights edit view is not supported for digital object type: ${digitalObject.digitalObjectType}`;
          }
        }}
        requiredAbility={{ action: 'assess_rights', primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects }}
      />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default Rights;

Rights.propTypes = {
  id: PropTypes.string.isRequired,
};
