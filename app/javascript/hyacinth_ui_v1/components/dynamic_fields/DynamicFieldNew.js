import React from 'react';
import queryString from 'query-string';

import ContextualNavbar from '../layout/ContextualNavbar';
import DynamicFieldForm from './DynamicFieldForm';
import DynamicFieldsBreadcrumbs from '../layout/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldNew extends React.PureComponent {
  render() {
    const { location: { search } } = this.props;
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
}

export default DynamicFieldNew;
