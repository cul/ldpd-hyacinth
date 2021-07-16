import React from 'react';

import PublishTargetForm from './PublishTargetForm';
import ContextualNavbar from '../shared/ContextualNavbar';

function PublishTargetNew() {
  return (
    <>
      <ContextualNavbar
        title="New Publish Target"
      />
      <PublishTargetForm formType="new" />
    </>
  );
}

export default PublishTargetNew;
