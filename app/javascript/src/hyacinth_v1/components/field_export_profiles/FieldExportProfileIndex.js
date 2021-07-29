import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../shared/ContextualNavbar';
import { fieldExportProfilesQuery } from '../../graphql/fieldExportProfiles';
import GraphQLErrors from '../shared/GraphQLErrors';

function FieldExportProfileIndex() {
  const { loading, error, data } = useQuery(fieldExportProfilesQuery);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Field Export Profiles"
        rightHandLinks={[{ link: '/field_export_profiles/new', label: 'New Field Export Profile' }]}
      />

      <Table hover responsive>
        <thead>
          <tr>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {
            data.fieldExportProfiles && (
              data.fieldExportProfiles.map(fieldExportProfile => (
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

export default FieldExportProfileIndex;
