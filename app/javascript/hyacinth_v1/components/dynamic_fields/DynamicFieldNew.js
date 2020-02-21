import React from 'react';
import queryString from 'query-string';
import { useLocation } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldForm from './DynamicFieldForm';
import DynamicFieldsBreadcrumbs from '../shared/dynamic_fields/DynamicFieldsBreadcrumbs';

function DynamicFieldNew() {
  const { search } = useLocation();

  const { dynamicFieldGroupId } = queryString.parse(search);

  return (
    <>
      <ContextualNavbar
        title="Create Dynamic Field"
        rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
      />

      <DynamicFieldsBreadcrumbs
        for={{ id: dynamicFieldGroupId, type: 'DynamicFieldGroup' }}
        last="New Dynamic Field"
      />

      <DynamicFieldForm formType="new" defaultValues={{ dynamicFieldGroupId }} />
    </>
  );
}

export default DynamicFieldNew;
