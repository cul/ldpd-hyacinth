import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldForm from './DynamicFieldForm';
import DynamicFieldsBreadcrumbs from '../shared/dynamic_fields/DynamicFieldsBreadcrumbs';
import { getDynamicFieldQuery } from '../../graphql/dynamicFields';
import GraphQLErrors from '../shared/GraphQLErrors';

function DynamicFieldEdit() {
  const { id } = useParams();

  const { loading, error, data } = useQuery(
    getDynamicFieldQuery, { variables: { id } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Update Dynamic Field"
        rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
      />

      <DynamicFieldsBreadcrumbs for={{ id, type: 'DynamicField' }} />

      <DynamicFieldForm formType="edit" dynamicField={data.dynamicField} />
    </>
  );
}

export default DynamicFieldEdit;
