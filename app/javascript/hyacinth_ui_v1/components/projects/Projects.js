import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import ProjectIndex from './ProjectIndex';
import ProjectNew from './ProjectNew';
import Project from './Project';
import ProtectedRoute from '../ProtectedRoute';

function Projects() {
  return (
    <Switch>
      <Route exact path="/projects" component={ProjectIndex} />

      <ProtectedRoute
        requiredAbility={{ action: 'create', subjectType: 'Project' }}
        path="/projects/new"
        component={ProjectNew}
      />

      <Route path="/projects/:stringKey" component={Project} />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default Projects;
