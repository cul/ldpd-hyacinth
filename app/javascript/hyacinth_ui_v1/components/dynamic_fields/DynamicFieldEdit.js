import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import DynamicFieldForm from './DynamicFieldForm';
import DynamicFieldsBreadcrumbs from '../layout/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldGroupNew extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Create Dynamic Field"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldsBreadcrumbs for={{ id, type: 'DynamicField' }} />

        <DynamicFieldForm formType="edit" id={id} key={id} />
      </>
    );
  }
}

export default DynamicFieldGroupNew;
