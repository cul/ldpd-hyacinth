import React from 'react';
import PropTypes from 'prop-types';

class TabBody extends React.PureComponent {
  render() {
    const { children } = this.props;

    return (
      <div className="m-3">{children}</div>
    );
  }
}

TabBody.propTypes = {
  children: PropTypes.node.isRequired,
};

export default TabBody;
