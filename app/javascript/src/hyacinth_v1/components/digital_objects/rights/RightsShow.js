import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { get } from 'lodash';

import GraphQLErrors from '../../shared/GraphQLErrors';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import { rightsFieldsQuery } from '../../../graphql/rightsFields';
import RightsTab from './RightsTab';
import { digitalObjectAbility } from '../../../utils/ability';
import DisplayFieldGroup from '../common/DisplayFieldGroup';

function RightsShow(props) {
  const { id } = props;

  // Retrieve Rights for Digital Object
  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getRightsDigitalObjectQuery, { variables: { id } });

  // Retrieve Rights Fields based on Digital Object Type
  const {
    loading: rightsFieldsLoading,
    error: rightsFieldsError,
    data: rightsFieldsData,
  } = useQuery(rightsFieldsQuery, {
    skip: !digitalObjectData,
    variables: { metadataForm: digitalObjectData && `${digitalObjectData.digitalObject.digitalObjectType}_RIGHTS` },
  });

  if (digitalObjectLoading || rightsFieldsLoading) return (<></>);
  if (digitalObjectError || rightsFieldsError) {
    return (<GraphQLErrors errors={digitalObjectError || rightsFieldsError} />);
  }

  const {
    digitalObject,
    digitalObject: {
      primaryProject, otherProjects, rights,
    },
  } = digitalObjectData;

  const { dynamicFieldCategories } = rightsFieldsData;

  const canEdit = digitalObjectAbility.can('assess_rights', { primaryProject, otherProjects });

  const rightsAssigned = Object.values(rights).find((value) => value.length);

  return (
    <RightsTab digitalObject={digitalObject} editButton={canEdit}>
      {
        !rightsAssigned
        && <p className="text-center">Rights for this object have not been assigned. Please click the edit button to assign rights.</p>
        }
      {
        rightsAssigned && get(dynamicFieldCategories, '[0].children') && dynamicFieldCategories[0].children.map((group) => (
          <DisplayFieldGroup
            key={group.id}
            data={rights[group.stringKey] || []}
            dynamicFieldGroup={group}
          />
        ))
      }
    </RightsTab>
  );
}

export default RightsShow;

RightsShow.propTypes = {
  id: PropTypes.string.isRequired,
};
