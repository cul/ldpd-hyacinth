import React from 'react';
import { Route } from 'react-router-dom';

import ability from '../util/ability';
import PageNotFound from './layout/PageNotFound';

class ProtectedRoute extends React.PureComponent {
  render() {
    const {
      component: Component,
      requiredAbility,
      ...rest
    } = this.props;

    const { computedMatch: { params } } = this.props;

    let {
      action,
      subject: subjectType,
      ...subject
    } = (typeof (requiredAbility) === 'function') ? requiredAbility(params) : requiredAbility;

    if (subjectType) {
      subject = { subjectType, ...subject };
    }

    const can = ability.can(action, subject);

    return (
      <Route
        {...rest}
        render={
          props => (can ? <Component {...props} /> : <PageNotFound />)
        }
      />
    );
  }
}

export default ProtectedRoute;
