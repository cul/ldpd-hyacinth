import React from 'react';
import PropTypes from 'prop-types';

function TabBody(props) {
  const { children } = props;

  return <div className="m-3">{children}</div>;
}

TabBody.propTypes = {
  children: PropTypes.node.isRequired,
};

export default TabBody;
