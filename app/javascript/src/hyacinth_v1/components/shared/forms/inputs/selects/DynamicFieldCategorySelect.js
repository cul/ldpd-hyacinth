import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import SelectInput from '../SelectInput';
import { getDynamicFieldCategoriesQuery } from '../../../../../graphql/dynamicFieldCategories';
import GraphQLErrors from '../../../GraphQLErrors';

function DynamicFieldCategorySelect(props) {
  const { loading, error, data } = useQuery(getDynamicFieldCategoriesQuery);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const options = data.dynamicFieldCategories.map((c) => ({ label: c.displayLabel, value: c.id }));

  return (
    <SelectInput sm={4} options={options} {...props} />
  );
}

DynamicFieldCategorySelect.propTypes = {
  value: PropTypes.string.isRequired,
};

export default DynamicFieldCategorySelect;
