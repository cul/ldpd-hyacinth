import React from 'react';
import { Route, Switch } from 'react-router-dom';
import queryString from 'query-string';

import PageNotFound from '../layout/PageNotFound';
import DigitalObjectSearch from './DigitalObjectSearch';
import DigitalObjectNew from './DigitalObjectNew';
import DigitalObjectEdit from './DigitalObjectEdit';
import DigitalObjectShow from './DigitalObjectShow';
import DigitalObjectChildren from './DigitalObjectChildren';

import ParentDigitalObjectForm from './ParentDigitalObjectForm';

import Rights from './rights/Rights';

export default class DigitalObjects extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/digital_objects" component={DigitalObjectSearch} />

          <Route
            path="/digital_objects/new"
            render={(props) => {
              const { location: { search } } = props;
              const { project, parent, digitalObjectType } = queryString.parse(search);

              if (parent && digitalObjectType === 'asset') {
                return <></>;
              }

              if (project && digitalObjectType !== 'asset') {
                return (
                  <ParentDigitalObjectForm
                    digitalObjectType={digitalObjectType}
                    project={project}
                  />
                );
              }

              return <DigitalObjectNew />;
            }}
          />

          <Route path="/digital_objects/:id/edit" component={DigitalObjectEdit} />
          <Route path="/digital_objects/:id/children" component={DigitalObjectChildren} />
          <Route path="/digital_objects/:id/rights" component={Rights} />
          <Route path="/digital_objects/:id" component={DigitalObjectShow} />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
