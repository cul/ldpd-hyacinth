import React from 'react';

import ContextualNavbar from '../shared/ContextualNavbar';
import FieldExportProfileForm from './FieldExportProfileForm';

function FieldExportProfileNew() {
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

export default FieldExportProfileNew;
