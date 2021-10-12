import React from 'react';
import PropTypes from 'prop-types';

const ProjectShow = ({ stringKey, displayLabel }) => (
  <span className="badge bg-secondary" key={stringKey}>{displayLabel}</span>
);

ProjectShow.propTypes = {
  stringKey: PropTypes.string.isRequired,
  displayLabel: PropTypes.string.isRequired,
};

export default ProjectShow;
