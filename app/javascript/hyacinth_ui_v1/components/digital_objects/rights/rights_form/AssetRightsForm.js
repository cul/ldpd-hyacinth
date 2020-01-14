import React from 'react';
import produce from 'immer';
import { Form } from 'react-bootstrap';

import ContextualNavbar from '../../../layout/ContextualNavbar';
import CopyrightStatus from './subsections/CopyrightStatus';
import AccessCondition from './subsections/AccessCondition';

class AssetRightsForm extends React.Component {
  state = {
    rights: {
      accessCondition: {
        accessCondition: '', // This eventually needs to be multivalued.
        embargoReleaseDate: '',
        note: '',
      },
      copyrightStatusOverride: {
        copyrightStatement: '',
        copyrightNote: [''],
        copyrightRegistered: '',
        copyrightRenewed: '',
        copyrightDateOfRenewal: '',
        copyrightExpirationDate: '',
        culCopyrightAssessmentDate: '',
      },
    },
  }

  onChange(subsection, value) {
    this.setState(produce((draft) => {
      draft.rights[subsection] = value;
    }));
  }

  render() {
    const { rights: { copyrightStatusOverride, accessCondition } } = this.state;

    return (
      <>
        <ContextualNavbar
          title="Editing Asset Rights"
          rightHandLinks={[
            { link: '/digital_objects', label: 'Cancel' },
          ]}
        />

        <Form className="mb-3">
          <AccessCondition
            value={accessCondition}
            onChange={v => this.onChange('accessCondition', v)}
          />
          <CopyrightStatus
            title="Asset Copyright Status Override"
            value={copyrightStatusOverride}
            onChange={v => this.onChange('copyrightStatusOverride', v)}
          />
        </Form>

      </>
    );
  }
}

export default AssetRightsForm;
