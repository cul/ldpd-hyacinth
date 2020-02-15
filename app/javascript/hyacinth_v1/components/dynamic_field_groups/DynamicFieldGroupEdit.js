import React from 'react';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';
import DynamicFieldsBreadcrumbs from '../shared/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldGroupEdit extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Update Dynamic Field Group"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldsBreadcrumbs for={{ id, type: 'DynamicFieldGroup' }} />

        <DynamicFieldGroupForm formType="edit" key={id} id={id} />
      </>
    );
  }
}

export default DynamicFieldGroupEdit;
