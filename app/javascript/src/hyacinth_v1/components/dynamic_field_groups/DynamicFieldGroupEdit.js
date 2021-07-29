import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';
import DynamicFieldsBreadcrumbs from '../shared/dynamic_fields/DynamicFieldsBreadcrumbs';
import { getDynamicFieldGroupQuery } from '../../graphql/dynamicFieldGroups';
import GraphQLErrors from '../shared/GraphQLErrors';

function DynamicFieldGroupEdit() {
  const { id } = useParams();

  const { loading, error, data } = useQuery(
    getDynamicFieldGroupQuery, { variables: { id } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Update Dynamic Field Group"
        rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
      />

      <DynamicFieldsBreadcrumbs for={{ id, type: 'DynamicFieldGroup' }} />

      <DynamicFieldGroupForm formType="edit" dynamicFieldGroup={data.dynamicFieldGroup} />
    </>
  );
}

export default DynamicFieldGroupEdit;
