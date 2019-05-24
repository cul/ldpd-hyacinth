import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import producer from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';

export default class FieldExportProfileIndex extends React.Component {
  state = {
    fieldExportProfiles: [],
  }

  componentDidMount() {
    hyacinthApi.get('/field_export_profiles')
      .then((res) => {
        this.setState(producer((draft) => { draft.fieldExportProfiles = res.data.fieldExportProfiles; }));
      });
  }

  render() {
    const { fieldExportProfiles } = this.state;

    return (
      <>
        <ContextualNavbar
          title="Field Export Profiles"
          rightHandLinks={[{ link: '/field_export_profiles/new', label: 'New Field Export Profile' }]}
        />

        <Table hover>
          <thead>
            <tr>
              <th>Name</th>
            </tr>
          </thead>
          <tbody>
            {
              fieldExportProfiles && (
                fieldExportProfiles.map(fieldExportProfile => (
                  <tr key={fieldExportProfile.id}>
                    <td><Link to={`/field_export_profiles/${fieldExportProfile.id}/edit`}>{fieldExportProfile.name}</Link></td>
                  </tr>
                ))
              )
            }
          </tbody>
        </Table>
      </>
    );
  }
}
