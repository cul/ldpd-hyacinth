import React from 'react';
import PropTypes from 'prop-types';

class ProjectSubHeading extends React.PureComponent {
  render() {
    const { children } = this.props;

    return (
      <h4 className="mb-3 pt-2 pb-1 text-center">{children}</h4>
    );
  }
}

ProjectSubHeading.propTypes = {
  children: PropTypes.node.isRequired,
};

export default ProjectSubHeading;
