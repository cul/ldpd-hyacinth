import React from 'react';
import PropTypes from 'prop-types';
import { Route } from 'react-router-dom';

import ability from '../../../utils/ability';
import PageNotFound from '../PageNotFound';

function DigitalObjectProtectedRoute(props) {
  const {
    requiredAbility,
    ...rest
  } = props;

  const { action, primaryProject, otherProjects } = requiredAbility;
  const allProjects = [primaryProject].concat(otherProjects);

  let can = false;
  for (let i = 0; i < allProjects.length; i += 1) {
    if (ability.can(action, { subjectType: 'Project', stringKey: allProjects[i].stringKey })) {
      can = true;
      break;
    }
  }

  if (can) { return <Route {...rest} />; }
  return <PageNotFound />;
}

DigitalObjectProtectedRoute.propTypes = {
  requiredAbility: PropTypes.shape({
    primaryProject: PropTypes.object.isRequired,
    otherProjects: PropTypes.array.isRequired,
  }).isRequired,
};

export default DigitalObjectProtectedRoute;
