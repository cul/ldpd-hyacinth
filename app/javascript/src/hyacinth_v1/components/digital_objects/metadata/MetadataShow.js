import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import MetadataTab from './MetadataTab';
import { dynamicFieldCategories } from '../../../utils/hyacinthApi';
import { getMetadataDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { digitalObjectAbility } from '../../../utils/ability';
import DisplayFieldCategory from '../common/DisplayFieldCategory';
import DisplayTitle from '../common/DisplayTitle';
import { getDynamicFieldGraphQuery } from '../../../graphql/dynamicFieldCategories';

function MetadataShow(props) {
  const { id } = props;

  const [dynamicFieldHierarchy, setDynamicFieldHierarchy] = useState(null);

  // TODO: Replace effect below with GraphQL when we have a GraphQL DynamicFieldCategories API
  // const {
  //   loading: fieldGraphLoading, error: fieldGraphError, data: fieldGraphData,
  // } = useQuery(getDynamicFieldGraphQuery, { variables: { metadataForm: 'DESCRIPTIVE' } });
  useEffect(() => {
    dynamicFieldCategories.all().then((res) => {
      setDynamicFieldHierarchy(res.data.dynamicFieldCategories);
    });
  }, []);

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getMetadataDigitalObjectQuery, {
    variables: { id },
  });

  if (!dynamicFieldHierarchy) return (<></>);
  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);

  const {
    digitalObject,
    digitalObject: {
      identifiers, descriptiveMetadata, otherProjects, primaryProject,
    },
  } = digitalObjectData;

  const canEdit = digitalObjectAbility.can('update_objects', { primaryProject, otherProjects });

  return (
    <MetadataTab digitalObject={digitalObject} editButton={canEdit}>
      <DisplayTitle data={digitalObject} />
      {
        dynamicFieldHierarchy.map((category) => (
          <DisplayFieldCategory
            key={category.id}
            data={descriptiveMetadata}
            dynamicFieldCategory={category}
          />
        ))
      }
      <h4 className="text-orange">Identifiers</h4>
      <ul className="list-unstyled">
        {identifiers.length ? identifiers.map((identifier) => <li key={identifier}>{identifier}</li>) : '- None -'}
      </ul>
    </MetadataTab>
  );
}

export default MetadataShow;

MetadataShow.propTypes = {
  id: PropTypes.string.isRequired,
};
