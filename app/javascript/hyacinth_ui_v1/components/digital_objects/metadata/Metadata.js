import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import MetadataShow from './MetadataShow';
import MetadataEdit from './MetadataEdit';

class Metadata extends React.PureComponent {
  render() {
    return (
      <Switch>
        <Route exact path="/digital_objects/:id/metadata" component={MetadataShow} />
        <Route path="/digital_objects/:id/metadata/edit" component={MetadataEdit} />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}

export default Metadata;
