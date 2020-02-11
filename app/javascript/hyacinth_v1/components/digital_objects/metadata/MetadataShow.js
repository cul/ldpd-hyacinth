import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import MetadataTab from './MetadataTab';
import { dynamicFieldCategories } from '../../../util/hyacinth_api';
import InputGroup from '../../shared/forms/InputGroup';
import Label from '../../shared/forms/Label';
import PlainText from '../../shared/forms/inputs/PlainText';
import { getMetadataDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { digitalObjectAbility } from '../../../util/ability';

function MetadataShow(props) {
  const { id } = props;

  const [dynamicFieldHierarchy, setDynamicFieldHierarchy] = useState(null);

  // TODO: Replace effect below with GraphQL when we have a GraphQL DynamicFieldCategories API
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

  const { digitalObject } = digitalObjectData;
  const { identifiers, dynamicFieldData, primaryProject } = digitalObject;

  const renderField = (dynamicField, data) => {
    const { displayLabel, fieldType } = dynamicField;

    return (
      <InputGroup key={dynamicField.stringKey}>
        <Label align="right">{displayLabel}</Label>
        <PlainText value={fieldType === 'controlled_term' ? (data.pref_label || data.prefLabel) : data } />
      </InputGroup>
    );
  };

  const renderGroup = (dynamicGroup, data) => {
    const {
      stringKey, displayLabel, isRepeatable, children,
    } = dynamicGroup;

    return (
      data.map((d, i) => (
        <Card key={`${stringKey}_${i + 1}`}>
          <Card.Header>
            {displayLabel}
            {isRepeatable ? ` ${i + 1}` : ''}
          </Card.Header>
          <Card.Body>
            {
              children.map((c) => {
                if (d[c.stringKey]) {
                  if (c.type === 'DynamicFieldGroup') {
                    return renderGroup(c, d[c.stringKey]);
                  } if (c.type === 'DynamicField') {
                    return renderField(c, d[c.stringKey]);
                  }
                }
                return '';
              })
            }
          </Card.Body>
        </Card>
      ))
    );
  };

  const renderCategory = (dynamicCategory, data) => {
    const { displayLabel, children } = dynamicCategory;

    const filteredChildren = children.filter(c => data[c.stringKey]);

    return (
      filteredChildren.length
        ? (
          <div key={displayLabel}>
            <h4 className="text-orange">{displayLabel}</h4>
            {
              filteredChildren.map(c => renderGroup(c, data[c.stringKey]))
            }
          </div>
        )
        : ''
    );
  };

  const canEdit = digitalObjectAbility.can('update_objects', { primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects });

  return (
    <MetadataTab digitalObject={digitalObject} editButton={canEdit}>
      { dynamicFieldHierarchy.map(category => renderCategory(category, dynamicFieldData)) }
      <h4 className="text-orange">Identifiers</h4>
      <ul className="list-unstyled">
        { identifiers.length ? identifiers.map((identifier, i) => <li key={i}>{identifier}</li>) : '- None -'}
      </ul>
    </MetadataTab>
  );
}

export default MetadataShow;

MetadataShow.propTypes = {
  id: PropTypes.string.isRequired,
};
