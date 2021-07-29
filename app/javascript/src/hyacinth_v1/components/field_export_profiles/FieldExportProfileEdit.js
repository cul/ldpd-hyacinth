import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../shared/ContextualNavbar';
import FieldExportProfileForm from './FieldExportProfileForm';
import { fieldExportProfileQuery } from '../../graphql/fieldExportProfiles';
import GraphQLErrors from '../shared/GraphQLErrors';

function FieldExportProfileEdit() {
  const { id } = useParams();

  const { loading, error, data } = useQuery(
    fieldExportProfileQuery, {
      variables: { id },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Update Field Export Profile"
        rightHandLinks={[{ link: '/field_export_profiles', label: 'Back to All Field Export Profiles' }]}
      />

      <FieldExportProfileForm formType="edit" fieldExportProfile={data.fieldExportProfile} />
    </>
  );
}

export default FieldExportProfileEdit;
