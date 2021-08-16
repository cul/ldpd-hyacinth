import React, { Suspense } from 'react';
import PropTypes from 'prop-types';

const LazyJSONInput = React.forwardRef((props, ref) => {
  const { fallback, ...rest } = props;
  const JSONInput = React.lazy(() => import(/* webpackChunkName: 'jsonEditor' */ './JSONInput'));
  return <Suspense fallback={fallback}><JSONInput ref={ref} { ...rest } /></Suspense>;
});

LazyJSONInput.propTypes = {
  fallback: PropTypes.object,
};

LazyJSONInput.defaultProps = {
  fallback: <div>Loading...</div>,
};

export default LazyJSONInput;
