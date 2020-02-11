import React from 'react';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldForm from './DynamicFieldForm';
import DynamicFieldsBreadcrumbs from '../shared/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldEdit extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Update Dynamic Field"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldsBreadcrumbs for={{ id, type: 'DynamicField' }} />

        <DynamicFieldForm formType="edit" id={id} key={id} />
      </>
    );
  }
}

export default DynamicFieldEdit;
