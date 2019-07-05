import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import MetadataShow from './MetadataShow';
import MetadataForm from './MetadataForm';

class Metadata extends React.PureComponent {
  render() {
    return (
      <Switch>
        <Route exact path="/digital_objects/:id/metadata" component={MetadataShow} />
        <Route
          path="/digital_objects/:id/metadata/edit"
          render={() => <MetadataForm formType="edit" />}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}

export default Metadata;
