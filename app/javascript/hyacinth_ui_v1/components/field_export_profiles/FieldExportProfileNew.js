import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import FieldExportProfileForm from './FieldExportProfileForm';

class DynamicFieldGroupNew extends React.PureComponent {
  render() {
    return (
      <>
        <ContextualNavbar
          title="Create Field Export Profile"
          rightHandLinks={[{ link: '/field_export_profiles', label: 'Back to All Field Export Profiles' }]}
        />

        <FieldExportProfileForm formType="new" />
      </>
    );
  }
}

export default DynamicFieldGroupNew;
