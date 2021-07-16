import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import { getDynamicFieldCategoryQuery } from '../../graphql/dynamicFieldCategories';
import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldCategoryForm from './DynamicFieldCategoryForm';
import GraphQLErrors from '../shared/GraphQLErrors';

function DynamicFieldCategoryEdit() {
  const { id } = useParams();

  const { loading, error, data } = useQuery(
    getDynamicFieldCategoryQuery, { variables: { id } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Edit Dynamic Field Category"
        rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
      />

      <DynamicFieldCategoryForm formType="edit" dynamicFieldCategory={data.dynamicFieldCategory} />
    </>
  );
}

export default DynamicFieldCategoryEdit;
