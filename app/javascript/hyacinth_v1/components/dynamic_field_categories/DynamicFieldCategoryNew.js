import React from 'react';

import ContextualNavbar from '../shared/ContextualNavbar';
import DynamicFieldCategoryForm from './DynamicFieldCategoryForm';

class DynamicFieldCategoryNew extends React.PureComponent {
  render() {
    return (
      <>
        <ContextualNavbar
          title="Create Dynamic Field Category"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldCategoryForm formType="new" />
      </>
    );
  }
}

export default DynamicFieldCategoryNew;
