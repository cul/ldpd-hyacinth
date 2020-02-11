import React from 'react';
import PropTypes from 'prop-types';

function TabHeading(props) {
  const { children } = props;

  return <h4 className="mb-3 pt-2 pb-1 text-center">{children}</h4>;
}

TabHeading.propTypes = {
  children: PropTypes.node.isRequired,
};

export default TabHeading;
