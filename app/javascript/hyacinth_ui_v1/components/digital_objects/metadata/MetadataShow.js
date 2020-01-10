import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';

import DigitalObjectInterface from '../NewDigitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';
import { dynamicFieldCategories } from '../../../util/hyacinth_api';
import InputGroup from '../../ui/forms/InputGroup';
import Label from '../../ui/forms/Label';
import PlainText from '../../ui/forms/inputs/PlainText';

function MetadataShow(props) {
  const [dynamicFieldHierarchy, setDynamicFieldHierarchy] = useState(null);
  const { digitalObject } = props;
  const { id, identifiers, dynamicFieldData } = digitalObject;

  // TODO: Replace effect below with GraphQL when we have a GraphQL DynamicFieldCategories API
  useEffect(() => {
    dynamicFieldCategories.all().then((res) => {
      setDynamicFieldHierarchy(res.data.dynamicFieldCategories);
    });
  }, []);

  if (!dynamicFieldHierarchy) return (<></>);

  const renderField = (dynamicField, data) => {
    const { displayLabel, fieldType } = dynamicField;

    return (
      <InputGroup key={dynamicField.stringKey}>
        <Label align="right">{displayLabel}</Label>
        <PlainText value={fieldType === 'controlled_term' ? data.prefLabel : data } />
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

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Metadata
        <EditButton
          className="float-right"
          size="lg"
          link={`/digital_objects/${id}/metadata/edit`}
        />
      </TabHeading>

      { dynamicFieldHierarchy.map(category => renderCategory(category, dynamicFieldData)) }
      <h4 className="text-orange">Identifiers</h4>
      <ul className="list-unstyled">
        { identifiers.length ? identifiers.map(i => <li>{i}</li>) : '- None -'}
      </ul>
    </DigitalObjectInterface>
  );
}

export default MetadataShow;

MetadataShow.propTypes = {
  digitalObject: PropTypes.object.isRequired,
};
