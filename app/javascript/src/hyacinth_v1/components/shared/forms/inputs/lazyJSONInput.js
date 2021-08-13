import React, { Suspense } from 'react';
import PropTypes from 'prop-types';

const LazyJSONInput = (props) => {
  const { fallback, ...rest } = props;
  const JSONInput = React.lazy(() => import(/* webpackChunkName: 'jsonEditor' */ './JSONInput'));
  return <Suspense fallback={fallback}><JSONInput { ...rest } /></Suspense>;
};

LazyJSONInput.propTypes = {
  fallback: PropTypes.object,
};

LazyJSONInput.defaultProps = {
  fallback: <div>Loading...</div>,
};

export default LazyJSONInput;
