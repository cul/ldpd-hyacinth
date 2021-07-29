import React from 'react';
import { useLocation } from 'react-router-dom';
import queryString from 'query-string';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';
import DynamicFieldsBreadcrumbs from '../shared/dynamic_fields/DynamicFieldsBreadcrumbs';

function DynamicFieldGroupNew() {
  const { search } = useLocation();

  const { parentType, parentId } = queryString.parse(search);

  return (
    <>
      <ContextualNavbar
        title="Create Dynamic Field Group"
        rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
      />

      <DynamicFieldsBreadcrumbs
        for={{ id: parentId, type: parentType }}
        last="New Dynamic Field Group"
      />

      <DynamicFieldGroupForm
        formType="new"
        defaultValues={{ parentType, parentId }}
      />
    </>
  );
}

export default DynamicFieldGroupNew;
