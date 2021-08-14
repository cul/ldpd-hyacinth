import React, { Suspense } from 'react';
import PropTypes from 'prop-types';

const LazyFontAwesomeIcon = (props) => {
  const { fallback, icon, ...rest } = props;
  const FontAwesomeIcon = React.lazy(() => import(/* webpackChunkName: 'fontAwesome' */ './fontAwesome'));
  return <Suspense fallback={fallback}><FontAwesomeIcon icon={icon} { ...rest } /></Suspense>;
};

LazyFontAwesomeIcon.propTypes = {
  fallback: PropTypes.object,
  icon: PropTypes.string.isRequired,
};

LazyFontAwesomeIcon.defaultProps = {
  fallback: <span />,
};

export default LazyFontAwesomeIcon;
