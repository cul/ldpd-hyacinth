import React, { Suspense } from 'react';
import PropTypes from 'prop-types';

const FontAwesomeIcon = React.lazy(() => import(/* webpackChunkName: 'fontAwesome' */ './fontAwesome'));

const LazyFontAwesomeIcon = (props) => {
  const { fallback, icon, ...rest } = props;
  return <Suspense fallback={fallback}><FontAwesomeIcon icon={icon} {...rest} /></Suspense>;
};

LazyFontAwesomeIcon.propTypes = {
  fallback: PropTypes.node,
  icon: PropTypes.string.isRequired,
};

LazyFontAwesomeIcon.defaultProps = {
  fallback: <span />,
};

export default LazyFontAwesomeIcon;
