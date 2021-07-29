import React from 'react';
import PropTypes from 'prop-types';
import DisplayFieldGroup from './DisplayFieldGroup';

function DynamicFieldCategory(props) {
  const {
    data,
    dynamicFieldCategory: { id, displayLabel, children },
  } = props;

  const filteredChildren = children.filter(c => data[c.stringKey]);

  if (filteredChildren.length < 1) return (<></>);

  return (
    <div key={id}>
      <h4 className="text-orange">{displayLabel}</h4>
      {
        filteredChildren.map(c => (
          <DisplayFieldGroup key={c.id} data={data[c.stringKey]} dynamicFieldGroup={c} />
        ))
      }
    </div>
  );
}

DynamicFieldCategory.propTypes = {
  dynamicFieldCategory: PropTypes.shape({
    displayLabel: PropTypes.string.isRequired,
    children: PropTypes.array.isRequired,
  }).isRequired,
};

export default DynamicFieldCategory;
