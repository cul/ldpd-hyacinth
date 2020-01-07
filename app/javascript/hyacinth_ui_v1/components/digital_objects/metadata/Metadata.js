import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import MetadataShow from './MetadataShow';
import MetadataEdit from './MetadataEdit';
import ProtectedRoute from '../../ProtectedRoute';

function Metadata(props) {
  // console.log(props);
  // const { minimalDigitalObject } = props;
  // const projects = [minimalDigitalObject.primaryProject].concat(minimalDigitalObject.otherProjects);

  return (
    <Switch>
      <Route exact path="/digital_objects/:id/metadata" component={MetadataShow} />
      <Route exact path="/digital_objects/:id/metadata/edit" component={MetadataEdit} />
      {/* <ProtectedRoute
        path="/digital_objects/:id/metadata/edit"
        component={MetadataEdit}
        requiredAbility={{ action: 'update_objects', subject: 'Project', subject_id: project[0].stringKey }}
      /> */}

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default Metadata;
