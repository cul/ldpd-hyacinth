import React from 'react';
import queryString from 'query-string';

import ContextualNavbar from '../layout/ContextualNavbar';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';
import DynamicFieldsBreadcrumbs from '../layout/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldGroupNew extends React.PureComponent {
  render() {
    const { location: { search } } = this.props;
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
}

export default DynamicFieldGroupNew;
